//
//  TapGesture.swift
//  https://github.com/Andre-Pham/Zilliax
//
//  Created by Andre Pham.
//

import UIKit

public class TapGesture: View {
    // MARK: Properties

    private lazy var gesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTapGesture(_:)))
    private var onGesture: ((_ gesture: UITapGestureRecognizer) -> Void)? = nil

    // MARK: Overridden Functions

    public override func setup() {
        super.setup()
        self.addGestureRecognizer(self.gesture)
    }

    // MARK: Functions

    @discardableResult
    public func setOnGesture(_ callback: ((_ gesture: UITapGestureRecognizer) -> Void)?) -> Self {
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
    public func setDelaysTouchesBegan(to state: Bool) -> Self {
        self.gesture.delaysTouchesBegan = state
        return self
    }

    @discardableResult
    public func setDelaysTouchesEnded(to state: Bool) -> Self {
        self.gesture.delaysTouchesEnded = state
        return self
    }

    @discardableResult
    public func setNumberOfTapsRequired(to count: Int) -> Self {
        self.gesture.numberOfTapsRequired = count
        return self
    }

    @discardableResult
    public func setNumberOfTouchesRequired(to count: Int) -> Self {
        self.gesture.numberOfTouchesRequired = count
        return self
    }

    @discardableResult
    public func setDelegate(to delegate: UIGestureRecognizerDelegate?) -> Self {
        self.gesture.delegate = delegate
        return self
    }

    @objc
    private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        self.onGesture?(gesture)
    }
}
