//
//  PanGesture.swift
//  https://github.com/Andre-Pham/Zilliax
//
//  Created by Andre Pham.
//

import UIKit

public class PanGesture: View {
    // MARK: Properties

    private var onGesture: ((_ gesture: UIPanGestureRecognizer) -> Void)? = nil

    // MARK: Overridden Functions

    public override func setup() {
        super.setup()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(_:)))
        self.addGestureRecognizer(panGesture)
    }

    // MARK: Functions

    @discardableResult
    public func setOnGesture(_ callback: ((_ gesture: UIPanGestureRecognizer) -> Void)?) -> Self {
        self.onGesture = callback
        return self
    }

    @objc
    private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        self.onGesture?(gesture)
    }
}
