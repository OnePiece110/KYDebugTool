//
//  KYLogIntercepter.swift
//  KYDebugTool
//
//  Created by Ye Keyon on 2024/1/25.
//

import UIKit

final class KYLogIntercepter {

    public static let shared = KYLogIntercepter()

    private var inputPipe: Pipe?
    private var outputPipe: Pipe?
    private let queue = DispatchQueue(
        label: "com.debugswift.log.interceptor.queue",
        qos: .default,
        attributes: .concurrent
    )

    var consoleOutput = [String]()

    weak var delegate: KYLogInterceptorDelegate?

    let logUrl: URL? = {
        if let path = NSSearchPathForDirectoriesInDomains(
            .cachesDirectory,
            .userDomainMask,
            true
        ).first {
            let documentsDirectory = URL(fileURLWithPath: path)
            return documentsDirectory.appendingPathComponent("\(Bundle.main.bundleIdentifier ?? "app")-output.log")
        }
        return nil
    }()

    func start() {
        if let logUrl {
            do {
                let header =
                    """
                    Start logger
                    DeviceID: \(UIDevice.current.identifierForVendor?.uuidString ?? "none")
                    """
                try header.write(to: logUrl, atomically: true, encoding: .utf8)
            } catch {}
        }

        openConsolePipe()
    }

    func reset() {
        consoleOutput.removeAll()
    }

    private func openConsolePipe() {
        setvbuf(stdout, nil, _IONBF, 0)
        
        inputPipe = Pipe()
        outputPipe = Pipe()

        guard let inputPipe, let outputPipe else {
            return
        }

        let pipeReadHandle = inputPipe.fileHandleForReading

        dup2(STDOUT_FILENO, outputPipe.fileHandleForWriting.fileDescriptor)

        dup2(inputPipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)

        // 监听 readHandle 通知
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePipeNotification),
            name: FileHandle.readCompletionNotification,
            object: pipeReadHandle
        )

        // 说明您希望收到通过管道传输的任何数据的通知
        pipeReadHandle.readInBackgroundAndNotify()
    }

    @objc
    func handlePipeNotification(notification: Notification) {
        inputPipe?.fileHandleForReading.readInBackgroundAndNotify()

        if let data = notification.userInfo?[NSFileHandleNotificationDataItem] as? Data,
           let str = String(data: data, encoding: String.Encoding.utf8),
           let logUrl {
            outputPipe?.fileHandleForWriting.write(data)

            queue.async(flags: .barrier) {
                do {
                    try str.appendLineToURL(logUrl)
                } catch {}
            }

            appendConsoleOutput(str)
        }
    }

    private func appendConsoleOutput(_ consoleOutput: String?) {
        guard let output = consoleOutput else { return }

        if !shouldIgnoreLog(output), shouldIncludeLog(output) {
            queue.async { [weak self] in
                self?.consoleOutput.append(output)
                DispatchQueue.main.async {
                    self?.delegate?.logUpdated()
                }
            }
        }
    }

    private func shouldIgnoreLog(_ log: String) -> Bool {
        KYDebugTool.Console.ignoredLogs.contains { log.contains($0) }
    }

    private func shouldIncludeLog(_ log: String) -> Bool {
        if KYDebugTool.Console.onlyLogs.isEmpty {
            return true
        } else {
            return KYDebugTool.Console.onlyLogs.contains { log.contains($0) }
        }
    }
}

extension String {
    func appendLineToURL(_ fileURL: URL) throws {
        try (self + "\n").appendToURL(fileURL)
    }

    func appendToURL(_ fileURL: URL) throws {
        if let data = data(using: .utf8) {
            try data.appendToURL(fileURL)
        }
    }
}

extension Data {
    func appendToURL(_ fileURL: URL) throws {
        if let fileHandle = try? FileHandle(forWritingTo: fileURL) {
            defer {
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.write(self)
        } else {
            try write(to: fileURL, options: .atomic)
        }
    }
}

protocol KYLogInterceptorDelegate: AnyObject {
    func logUpdated()
}
