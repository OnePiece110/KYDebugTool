//
//  UIImage+.swift
//  KYDebugTool
//
//  Created by Ye Keyon on 2024/1/24.
//

import UIKit

extension UIImage {
    static func named(_ imageName: String, default: String? = nil) -> UIImage? {
        if #available(iOS 13.0, *) {
            return UIImage.init(systemName: imageName)
        } else {
            return `default`?.image(with: [.foregroundColor: UIColor.white])
        }
    }

    func outline() -> UIImage? {
        guard let cgImage = cgImage else { return nil }

        let size = CGSize(width: cgImage.width, height: cgImage.height)

        UIGraphicsBeginImageContext(size)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        self.draw(in: rect, blendMode: .normal, alpha: 1.0)

        // Set the stroke color and width
        context.setStrokeColor(UIColor.black.cgColor)
        let strokeWidth = Double(cgImage.height) * 0.01
        context.setLineWidth(strokeWidth)

        // Draw the stroke
        context.stroke(rect)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}
