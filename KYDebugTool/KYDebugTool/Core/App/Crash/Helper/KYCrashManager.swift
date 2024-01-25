//
//  KYCrashManager.swift
//  KYDebugTool
//
//  Created by Ye Keyon on 2024/1/25.
//

import Foundation

enum KYCrashManager {

    static func register() {
        KYCrashHandler.shared.prepare()
    }

    static func save(crash: KYCrashModel) {
        let filePath = getDocumentsDirectory().appendingPathComponent(crash.type.fileName)

        var existingCrashes: [KYCrashModel] = []
        if let existingData = try? Data(contentsOf: filePath) {
            existingCrashes = (try? JSONDecoder().decode([KYCrashModel].self, from: existingData)) ?? []
        }

        existingCrashes.append(crash)

        do {
            let jsonData = try JSONEncoder().encode(existingCrashes)
            try jsonData.write(to: filePath)
        } catch {
            KYDebug.print("Error saving crash data: \(error)")
        }
    }

    static func recover(ofType type: KYCrashType) -> [KYCrashModel] {
        let filePath = getDocumentsDirectory().appendingPathComponent(type.fileName)

        do {
            let existingData = try Data(contentsOf: filePath)
            return try JSONDecoder().decode([KYCrashModel].self, from: existingData)
        } catch {
            KYDebug.print("Error recovering crash data: \(error)")
            return []
        }
    }

    static func delete(crash: KYCrashModel) {
        let filePath = getDocumentsDirectory().appendingPathComponent(crash.type.fileName)

        var existingCrashes: [KYCrashModel] = []
        if let existingData = try? Data(contentsOf: filePath) {
            existingCrashes = (try? JSONDecoder().decode([KYCrashModel].self, from: existingData)) ?? []
        }

        existingCrashes.removeAll { $0 == crash }

        do {
            let jsonData = try JSONEncoder().encode(existingCrashes)
            try jsonData.write(to: filePath)
        } catch {
            KYDebug.print("Error saving crash data: \(error)")
        }
    }

    static func deleteAll(ofType type: KYCrashType) {
        let filePath = getDocumentsDirectory().appendingPathComponent(type.fileName)

        do {
            try FileManager.default.removeItem(at: filePath)
        } catch {
            KYDebug.print("Error deleting all crash reports: \(error)")
        }
    }

    private static func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}

enum KYCrashType: String, Codable {
    case nsexception
    case signal

    var fileName: String { "\(rawValue)_crashes.json" }
}
