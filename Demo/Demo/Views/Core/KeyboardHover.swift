//
//  KeyboardHover.swift
//  https://github.com/Andre-Pham/Zilliax
//
//  Created by Andre Pham.
//

import UIKit

public class KeyboardHover {
    // MARK: Properties

    private weak var view: UIView? = nil
    private var bottomConstraint: NSLayoutConstraint? = nil
    private var padding: CGFloat = 0.0
    private var keyboardPadding: CGFloat = 0.0
    private var keyboardIsShown = false
    private var observers = [NSObjectProtocol]()

    // MARK: Computed Properties

    private var activePadding: CGFloat {
        return self.keyboardIsShown ? self.keyboardPadding : self.padding
    }

    // MARK: Lifecycle

    public init() {
        self.observers.append(NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main,
            using: { [weak self] notification in
                self?.handleKeyboardChange(isShown: true, notification: notification)
            }
        ))
        self.observers.append(NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main,
            using: { [weak self] notification in
                self?.handleKeyboardChange(isShown: false, notification: notification)
            }
        ))
    }

    deinit {
        for observer in self.observers {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    // MARK: Functions

    @discardableResult
    public func setView(to view: UIView) -> Self {
        self.bottomConstraint?.isActive = false
        self.bottomConstraint = nil
        self.view = view
        return self
    }

    @discardableResult
    public func configureBottomConstraint(to other: UIView? = nil, padding: CGFloat = 0.0, keyboardPadding: CGFloat? = nil) -> Self {
        guard let view = self.view else {
            assertionFailure("Expected view to be set")
            return self
        }
        self.padding = padding
        self.keyboardPadding = keyboardPadding ?? padding
        self.bottomConstraint?.isActive = false
        self.bottomConstraint = view.constrainToOnTopValue(of: other, padding: self.activePadding, layoutGuide: .keyboard)
        return self
    }

    private func handleKeyboardChange(isShown: Bool, notification: Notification) {
        self.keyboardIsShown = isShown
        // Keyboard notifications are delivered inside the keyboard's animation block, so this inherits its timing
        let keyboardDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.0
        assert(keyboardDuration.isZero || UIView.inheritedAnimationDuration > 0.0, "Expected to inherit keyboard's animation block timing")
        self.bottomConstraint?.constant = -self.activePadding
        self.view?.superview?.layoutIfNeeded()
    }
}
