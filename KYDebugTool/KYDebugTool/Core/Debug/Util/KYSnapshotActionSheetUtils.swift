//
//  KYSnapshotActionSheetUtils.swift
//  KYDebugTool
//
//  Created by Ye Keyon on 2024/1/25.
//

import UIKit

func makeActionSheet(
    snapshot: KYSnapshot,
    sourceView: UIView,
    sourcePoint: CGPoint,
    focusAction: @escaping (KYSnapshot) -> Void
) -> UIAlertController {
    let actionSheet = UIAlertController(
        title: nil,
        message: snapshot.element.shortDescription,
        preferredStyle: .actionSheet
    )

    actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Focus", comment: "Focus on the hierarchy associated with this element"), style: .default) { _ in
        focusAction(snapshot)
    })

    actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Show More Info", comment: "Log the description of this element"), style: .default) { _ in
        print(snapshot.element)
        UIApplication.topViewController()?.navigationController?.pushViewController(
            KYDebuggerDetailViewController(snapshot: snapshot),
            animated: true
        )
    })

    let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel the action"), style: .cancel, handler: nil)
    actionSheet.addAction(cancel)
    actionSheet.preferredAction = cancel
    actionSheet.popoverPresentationController?.sourceView = sourceView
    actionSheet.popoverPresentationController?.sourceRect = CGRect(origin: sourcePoint, size: .zero)

    return actionSheet
}

