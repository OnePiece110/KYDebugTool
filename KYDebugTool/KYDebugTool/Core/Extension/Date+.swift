//
//  Date+.swift
//  KYDebugTool
//
//  Created by Ye Keyon on 2024/1/25.
//

import Foundation

extension Date {
    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE',' dd' 'MMM' 'yyyy HH':'mm':'ss zzz"
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter
    }()

    enum DateFormatType: String {
        case `default` = "HH:mm:ss - dd/MM/yyyy"
    }

    func formatted(_ format: DateFormatType = .default) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        formatter.locale = Locale(identifier: "pt_BR")

        return formatter.string(from: self)
    }
}
