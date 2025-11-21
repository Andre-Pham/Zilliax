//
//  PanGesture.swift
//  https://github.com/Andre-Pham/Zilliax
//
//  Created by Andre Pham.
//

import UIKit

public class PanGesture: View {
    // MARK: Properties

    private lazy var gesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(_:)))
    private var onGesture: ((_ gesture: UIPanGestureRecognizer) -> Void)? = nil

    // MARK: Overridden Functions

    public override func setup() {
        super.setup()
        self.addGestureRecognizer(self.gesture)
    }

    // MARK: Functions

    @discardableResult
    public func setOnGesture(_ callback: ((_ gesture: UIPanGestureRecognizer) -> Void)?) -> Self {
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

    @objc
    private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        self.onGesture?(gesture)
    }
}
