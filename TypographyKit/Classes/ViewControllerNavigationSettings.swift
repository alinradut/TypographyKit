//
//  ViewControllerNavigationSettings.swift
//  TypographyKit
//
//  Created by Ross Butler on 12/21/18.
//

import Foundation
import UIKit

@objc public class ViewControllerNavigationSettings: NSObject {

    let actionButton: UIBarButtonItem.SystemItem
    let animated: Bool
    let autoClose: Bool
    let closeButtonAlignment: CloseButtonAlignment
    let closeButton: UIBarButtonItem.SystemItem
    let isModal: Bool
    let isNavigationBarHidden: Bool
    let shouldRefresh: Bool

    public init(actionButton: UIBarButtonItem.SystemItem = .action,
                animated: Bool = false,
                autoClose: Bool = true,
                closeButtonAlignment: CloseButtonAlignment = .closeButtonLeftExportButtonRight,
                closeButton: UIBarButtonItem.SystemItem = .done,
                isModal: Bool = false,
                isNavigationBarHidden: Bool = false,
                shouldRefresh: Bool = true) {
        self.actionButton = actionButton
        self.animated = animated
        self.autoClose = autoClose
        self.closeButtonAlignment = closeButtonAlignment
        self.closeButton = closeButton
        self.isModal = isModal
        self.isNavigationBarHidden = isNavigationBarHidden
        self.shouldRefresh = shouldRefresh
    }

}
