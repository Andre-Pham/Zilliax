//
//  NavigationController.swift
//  https://github.com/Andre-Pham/Zilliax
//
//  Created by Andre Pham.
//

import UIKit

public class NavigationController: UINavigationController, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    // MARK: Overridden Functions

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBarHidden(true, animated: false)
        self.delegate = self
        // Enable native edge-swipe back gesture even with a hidden nav bar
        self.interactivePopGestureRecognizer?.delegate = self
        self.interactivePopGestureRecognizer?.isEnabled = true
    }

    // MARK: Functions

    public func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController,
        animated: Bool
    ) {
        viewController.view.setBackgroundColor(to: Colors.fillForeground)
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // Only allow the pop gesture when there's something to pop
        return self.viewControllers.count > 1
    }

    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        // Prevent edge-swipe back from also panning scroll views underneath.
        if gestureRecognizer == self.interactivePopGestureRecognizer,
           otherGestureRecognizer.view is UIScrollView {
            return false
        }
        // Allow pop gesture to work alongside other gestures when reasonable
        return true
    }
}
