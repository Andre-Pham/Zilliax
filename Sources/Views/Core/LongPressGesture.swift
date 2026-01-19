//
//  LongPressGesture.swift
//  https://github.com/Andre-Pham/Zilliax
//
//  Created by Andre Pham.
//

import UIKit

public class LongPressGesture: View {
    // MARK: Properties

    private lazy var gesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPressGesture(_:)))
    private var onGesture: ((_ gesture: UILongPressGestureRecognizer) -> Void)? = nil

    // MARK: Overridden Functions

    public override func setup() {
        super.setup()
        self.addGestureRecognizer(self.gesture)
    }

    // MARK: Functions

    @discardableResult
    public func setOnGesture(_ callback: ((_ gesture: UILongPressGestureRecognizer) -> Void)?) -> Self {
        self.onGesture = callback
        return self
    }

    @discardableResult
    public func addGestureRecognizer(to view: UIView) -> Self {
        view.addGestureRecognizer(self.gesture)
        return self
    }

    @discardableResult
    public func setCancelsTouchesInView(to state: Bool) -> Self {
        self.gesture.cancelsTouchesInView = state
        return self
    }

    @discardableResult
    public func setMinimumPressDuration(to duration: TimeInterval) -> Self {
        self.gesture.minimumPressDuration = duration
        return self
    }

    @discardableResult
    public func setDelaysTouchesBegan(to state: Bool) -> Self {
        self.gesture.delaysTouchesBegan = state
        return self
    }

    @discardableResult
    public func setDelegate(to delegate: UIGestureRecognizerDelegate?) -> Self {
        self.gesture.delegate = delegate
        return self
    }

    @objc
    private func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
        self.onGesture?(gesture)
    }
}
