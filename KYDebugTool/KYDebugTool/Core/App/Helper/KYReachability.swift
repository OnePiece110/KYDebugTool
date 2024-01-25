//
//  KYReachability.swift
//  KYDebugTool
//
//  Created by Ye Keyon on 2024/1/25.
//

import Foundation
import SystemConfiguration
import CoreTelephony

enum ReachabilityError: Error {
    case failedToCreateWithAddress(sockaddr, Int32)
    case failedToCreateWithHostname(String, Int32)
    case unableToSetCallback(Int32)
    case unableToSetDispatchQueue(Int32)
    case unableToGetFlags(Int32)
}

@available(*, unavailable, renamed: "Notification.Name.reachabilityChanged")
let ReachabilityChangedNotification = NSNotification.Name("ReachabilityChangedNotification")

extension Notification.Name {
    static let reachabilityChanged = Notification.Name("reachabilityChanged")
}

class KYReachability {

    typealias NetworkReachable = (KYReachability) -> Void
    typealias NetworkUnreachable = (KYReachability) -> Void

    @available(*, unavailable, renamed: "Connection")
    enum NetworkStatus: CustomStringConvertible {
        case notReachable, reachableViaWiFi, reachableViaWWAN
        var description: String {
            switch self {
            case .reachableViaWWAN: return "Cellular"
            case .reachableViaWiFi: return "WiFi"
            case .notReachable: return "No Connection"
            }
        }
    }

    enum Connection: CustomStringConvertible {
        case none
        case unavailable, wifi, cellular
        var description: String {
            switch self {
            case .cellular: return "Cellular"
            case .wifi: return "WiFi"
            case .unavailable: return "No Connection"
            case .none: return "Unavailable"
            }
        }
    }

    var whenReachable: NetworkReachable?
    var whenUnreachable: NetworkUnreachable?

    /// 设置为“false”时在蜂窝连接时强制 Reachability.connection 为 .none（默认值“true”）
    var allowsCellularConnection: Bool

    var notificationCenter = NotificationCenter.default

    var connection: Connection {
        if flags == nil {
            try? setReachabilityFlags()
        }

        switch flags?.connection {
        case .unavailable, nil:
            return .unavailable
        case .cellular:
            return allowsCellularConnection ? .cellular : .unavailable
        case .wifi:
            return .wifi
        case .some(.none):
            return .unavailable
        }
    }

    private var isRunningOnDevice: Bool = {
        #if targetEnvironment(simulator)
        return false
        #else
        return true
        #endif
    }()

    private(set) var notifierRunning = false
    private let reachabilityRef: SCNetworkReachability
    private let reachabilitySerialQueue: DispatchQueue
    private let notificationQueue: DispatchQueue?
    private(set) var flags: SCNetworkReachabilityFlags? {
        didSet {
            guard flags != oldValue else { return }
            notifyReachabilityChanged()
        }
    }

    required init(
        reachabilityRef: SCNetworkReachability,
        queueQoS: DispatchQoS = .default,
        targetQueue: DispatchQueue? = nil,
        notificationQueue: DispatchQueue? = .main
    ) {
        self.allowsCellularConnection = true
        self.reachabilityRef = reachabilityRef
        self.reachabilitySerialQueue = DispatchQueue(
            label: "uk.co.ashleymills.reachability",
            qos: queueQoS,
            target: targetQueue
        )
        self.notificationQueue = notificationQueue
    }

    convenience init(
        hostname: String,
        queueQoS: DispatchQoS = .default,
        targetQueue: DispatchQueue? = nil,
        notificationQueue: DispatchQueue? = .main
    ) throws {
        guard let ref = SCNetworkReachabilityCreateWithName(nil, hostname) else {
            throw ReachabilityError.failedToCreateWithHostname(hostname, SCError())
        }
        self.init(
            reachabilityRef: ref,
            queueQoS: queueQoS,
            targetQueue: targetQueue,
            notificationQueue: notificationQueue
        )
    }

    convenience init(
        queueQoS: DispatchQoS = .default,
        targetQueue: DispatchQueue? = nil,
        notificationQueue: DispatchQueue? = .main
    ) throws {
        var zeroAddress = sockaddr()
        zeroAddress.sa_len = UInt8(MemoryLayout<sockaddr>.size)
        zeroAddress.sa_family = sa_family_t(AF_INET)

        guard let ref = SCNetworkReachabilityCreateWithAddress(nil, &zeroAddress) else {
            throw ReachabilityError.failedToCreateWithAddress(zeroAddress, SCError())
        }

        self.init(
            reachabilityRef: ref,
            queueQoS: queueQoS,
            targetQueue: targetQueue,
            notificationQueue: notificationQueue
        )
    }

    deinit {
        stopNotifier()
    }
}

extension KYReachability {

    func startNotifier() throws {
        guard !notifierRunning else { return }

        let callback: SCNetworkReachabilityCallBack = { _, flags, info in
            guard let info = info else { return }

            let weakifiedReachability = Unmanaged<ReachabilityWeakifier>.fromOpaque(info).takeUnretainedValue()

            weakifiedReachability.reachability?.flags = flags
        }

        let weakifiedReachability = ReachabilityWeakifier(reachability: self)
        let opaqueWeakifiedReachability = Unmanaged<ReachabilityWeakifier>
            .passUnretained(weakifiedReachability)
            .toOpaque()

        var context = SCNetworkReachabilityContext(
            version: 0,
            info: UnsafeMutableRawPointer(opaqueWeakifiedReachability),
            retain: { (info: UnsafeRawPointer) -> UnsafeRawPointer in
                let unmanagedWeakifiedReachability = Unmanaged<ReachabilityWeakifier>.fromOpaque(info)
                _ = unmanagedWeakifiedReachability.retain()
                return UnsafeRawPointer(unmanagedWeakifiedReachability.toOpaque())
            },
            release: { (info: UnsafeRawPointer) in
                let unmanagedWeakifiedReachability = Unmanaged<ReachabilityWeakifier>.fromOpaque(info)
                unmanagedWeakifiedReachability.release()
            },
            copyDescription: { (info: UnsafeRawPointer) -> Unmanaged<CFString> in
                let unmanagedWeakifiedReachability = Unmanaged<ReachabilityWeakifier>.fromOpaque(info)
                let weakifiedReachability = unmanagedWeakifiedReachability.takeUnretainedValue()
                let description = weakifiedReachability.reachability?.description ?? "nil"
                return Unmanaged.passRetained(description as CFString)
            }
        )

        if !SCNetworkReachabilitySetCallback(reachabilityRef, callback, &context) {
            stopNotifier()
            throw ReachabilityError.unableToSetCallback(SCError())
        }

        if !SCNetworkReachabilitySetDispatchQueue(reachabilityRef, reachabilitySerialQueue) {
            stopNotifier()
            throw ReachabilityError.unableToSetDispatchQueue(SCError())
        }

        try setReachabilityFlags()

        notifierRunning = true
    }

    func stopNotifier() {
        defer { notifierRunning = false }

        SCNetworkReachabilitySetCallback(reachabilityRef, nil, nil)
        SCNetworkReachabilitySetDispatchQueue(reachabilityRef, nil)
    }

    var description: String { flags?.description ?? "unavailable flags" }
}

extension KYReachability {

    private func setReachabilityFlags() throws {
        try reachabilitySerialQueue.sync { [weak self] in
            guard let self = self else { return }
            var flags = SCNetworkReachabilityFlags()
            if !SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags) {
                self.stopNotifier()
                throw ReachabilityError.unableToGetFlags(SCError())
            }

            self.flags = flags
        }
    }

    private func notifyReachabilityChanged() {
        let notify = { [weak self] in
            guard let self = self else { return }
            if self.connection != .unavailable {
                self.whenReachable?(self)
            } else {
                self.whenUnreachable?(self)
            }
            self.notificationCenter.post(name: .reachabilityChanged, object: self)
        }

        notificationQueue?.async(execute: notify) ?? notify()
    }
}

extension SCNetworkReachabilityFlags {

    typealias Connection = KYReachability.Connection

    var connection: Connection {
        guard isReachableFlagSet else { return .unavailable }

        // 如果我们可以访问，但不在 iOS 设备（即模拟器）上，则我们必须使用 WiFi
        #if targetEnvironment(simulator)
        return .wifi
        #else
        var connection = Connection.unavailable

        if !isConnectionRequiredFlagSet {
            connection = .wifi
        }

        if isConnectionOnTrafficOrDemandFlagSet {
            if !isInterventionRequiredFlagSet {
                connection = .wifi
            }
        }

        if isOnWWANFlagSet {
            connection = .cellular
        }

        return connection
        #endif
    }

    var isOnWWANFlagSet: Bool {
        #if os(iOS)
        return contains(.isWWAN)
        #else
        return false
        #endif
    }

    var isReachableFlagSet: Bool { contains(.reachable) }
    var isConnectionRequiredFlagSet: Bool { contains(.connectionRequired) }
    var isInterventionRequiredFlagSet: Bool { contains(.interventionRequired) }
    var isConnectionOnTrafficFlagSet: Bool { contains(.connectionOnTraffic) }
    var isConnectionOnDemandFlagSet: Bool { contains(.connectionOnDemand) }
    var isTransientConnectionFlagSet: Bool { contains(.transientConnection) }
    var isLocalAddressFlagSet: Bool { contains(.isLocalAddress) }
    var isDirectFlagSet: Bool { contains(.isDirect) }

    var isConnectionOnTrafficOrDemandFlagSet: Bool {
        !intersection([.connectionOnTraffic, .connectionOnDemand]).isEmpty
    }

    var isConnectionRequiredAndTransientFlagSet: Bool {
        intersection([.connectionRequired, .transientConnection]) == [.connectionRequired, .transientConnection]
    }

    var description: String {
        let W = isOnWWANFlagSet ? "W" : "-"
        let R = isReachableFlagSet ? "R" : "-"
        let c = isConnectionRequiredFlagSet ? "c" : "-"
        let t = isTransientConnectionFlagSet ? "t" : "-"
        let i = isInterventionRequiredFlagSet ? "i" : "-"
        let C = isConnectionOnTrafficFlagSet ? "C" : "-"
        let D = isConnectionOnDemandFlagSet ? "D" : "-"
        let l = isLocalAddressFlagSet ? "l" : "-"
        let d = isDirectFlagSet ? "d" : "-"

        return "\(W)\(R) \(c)\(t)\(i)\(C)\(D)\(l)\(d)"
    }
}

private class ReachabilityWeakifier {
    weak var reachability: KYReachability?
    init(reachability: KYReachability) {
        self.reachability = reachability
    }
}

enum KYNetworkType: Int, CaseIterable {
    case unknown
    case noConnection
    case wifi
    case cellular
    case ethernet
    case wwan2g
    case wwan3g
    case wwan4g
    case wwan5g
    case unknownTechnology

    var description: String {
        switch self {
        case .noConnection:
            return "No Connection"
        case .wifi:
            return "WiFi"
        case .cellular:
            return "Cellular"
        case .ethernet:
            return "Ethernet"
        case .wwan2g:
            return "2G"
        case .wwan3g:
            return "3G"
        case .wwan4g:
            return "4G"
        case .wwan5g:
            return "5G"
        case .unknown, .unknownTechnology:
            return "Unavailable"
        }
    }

    var icon: String {
        switch self {
        case .unknown, .unknownTechnology:
            return "mdi:help-circle"
        case .noConnection:
            return "mdi:sim-off"
        case .wifi:
            return "mdi:wifi"
        case .cellular:
            return "mdi:signal"
        case .ethernet:
            return "mdi:ethernet"
        case .wwan2g:
            return "mdi:signal-2g"
        case .wwan3g:
            return "mdi:signal-3g"
        case .wwan4g:
            return "mdi:signal-4g"
        case .wwan5g:
            return "mdi:signal-5g"
        }
    }

    #if os(iOS) && !targetEnvironment(macCatalyst)
    init(_ radioTech: String) {
        if #available(iOS 14.1, *) {
            if [CTRadioAccessTechnologyNR, CTRadioAccessTechnologyNRNSA].contains(radioTech) {
                // 虽然这些在 14.0 中声明可用，但在 14.1 之前使用时会崩溃
                self = .wwan5g
                return
            }
        }

        switch radioTech {
        case CTRadioAccessTechnologyGPRS,
             CTRadioAccessTechnologyEdge,
             CTRadioAccessTechnologyCDMA1x:
            self = .wwan2g
        case CTRadioAccessTechnologyWCDMA,
             CTRadioAccessTechnologyHSDPA,
             CTRadioAccessTechnologyHSUPA,
             CTRadioAccessTechnologyCDMAEVDORev0,
             CTRadioAccessTechnologyCDMAEVDORevA,
             CTRadioAccessTechnologyCDMAEVDORevB,
             CTRadioAccessTechnologyeHRPD:
            self = .wwan3g
        case CTRadioAccessTechnologyLTE:
            self = .wwan4g
        default:
            self = .unknownTechnology
        }
    }
    #endif
}

#if os(iOS)
extension KYReachability {
    func getSimpleNetworkType() -> KYNetworkType {
        try? startNotifier()

        switch connection {
        case .none:
            return .noConnection
        case .wifi:
            return .wifi
        case .cellular:
            return .cellular
        case .unavailable:
            return .noConnection
        }
    }

    func getNetworkType() -> KYNetworkType {
        try? startNotifier()

        switch connection {
        case .none:
            return .noConnection
        case .wifi:
            return .wifi
        case .cellular:
            #if !targetEnvironment(macCatalyst)
            return KYReachability.getWWANNetworkType()
            #else
            return .cellular
            #endif
        case .unavailable:
            return .noConnection
        }
    }

    #if !targetEnvironment(macCatalyst)
    static func getWWANNetworkType() -> KYNetworkType {
        let networkTypes = (CTTelephonyNetworkInfo().serviceCurrentRadioAccessTechnology ?? [:])
            .sorted(by: { $0.key < $1.key })
            .map(\.value)
            .map(KYNetworkType.init(_:))

        return networkTypes.first(where: { $0 != .unknownTechnology }) ?? .unknown
    }
    #endif
}
#endif
