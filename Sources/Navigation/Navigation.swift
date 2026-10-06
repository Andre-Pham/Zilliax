//
//  Navigation.swift
//  https://github.com/Andre-Pham/Zilliax
//
//  Created by Andre Pham.
//

import UIKit

public enum Navigation {
    public static func present(
        from sourceViewController: UIViewController?,
        to targetViewController: UIViewController?,
        style: UIModalPresentationStyle = .formSheet,
        animated: Bool = true
    ) {
        guard let sourceViewController, let targetViewController else {
            assertionFailure("Expected view controllers to be defined")
            return
        }
        targetViewController.modalPresentationStyle = style
        sourceViewController.present(targetViewController, animated: animated)
    }

    public static func push(
        from sourceViewController: UIViewController?,
        to targetViewController: UIViewController?,
        animated: Bool = true
    ) {
        guard let sourceViewController, let targetViewController else {
            assertionFailure("Expected view controllers to be defined")
            return
        }
        guard let nav = sourceViewController.navigationController else {
            assertionFailure("Expected navigation controller")
            return
        }
        nav.pushViewController(targetViewController, animated: animated)
    }

    public static func pop(_ viewController: UIViewController?, animated: Bool = true) {
        guard let viewController else {
            assertionFailure("Expected view controller to be defined")
            return
        }
        guard let nav = viewController.navigationController else {
            assertionFailure("Expected navigation controller")
            return
        }
        nav.popViewController(animated: animated)
    }

    public static func dismiss(_ viewController: UIViewController?, animated: Bool = true) {
        guard let viewController else {
            assertionFailure("Expected view controller to be defined")
            return
        }
        viewController.dismiss(animated: animated)
    }
}
