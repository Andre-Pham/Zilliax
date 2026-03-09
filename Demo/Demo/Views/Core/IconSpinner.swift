//
//  IconSpinner.swift
//  https://github.com/Andre-Pham/Zilliax
//
//  Created by Andre Pham.
//

import UIKit

public class IconSpinner: IconImage {
    // MARK: Static Properties

    private static let DEFAULT_SIZE = 32.0
    private static let ROTATION_KEY = "rotation"

    // MARK: Overridden Functions

    public override func setup() {
        super.setup()

        self.setSymbol(systemName: "arrow.triangle.2.circlepath")
            .setSize(to: Self.DEFAULT_SIZE)
            .setColor(to: Colors.textDark)
    }

    public override func didMoveToWindow() {
        super.didMoveToWindow()
        if self.window != nil {
            self.startAnimating()
        } else {
            self.stopAnimating()
        }
    }

    public override func startAnimating() {
        if self.layer.animation(forKey: Self.ROTATION_KEY) != nil {
            return
        }
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = 0
        animation.toValue = Double.pi * 2.0
        animation.duration = 1.1
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        self.layer.add(animation, forKey: Self.ROTATION_KEY)
    }

    public override func stopAnimating() {
        self.layer.removeAnimation(forKey: Self.ROTATION_KEY)
    }
}
