//
//  ProgressBar.swift
//  https://github.com/Andre-Pham/Zilliax
//
//  Created by Andre Pham.
//

import UIKit

public class ProgressBar: View {
    // MARK: Static Properties

    private static let DEFAULT_HEIGHT = 16.0

    // MARK: Properties

    private let fill = View()
    private var heightConstraint: NSLayoutConstraint!
    private var fillWidthConstraint: NSLayoutConstraint!

    // MARK: Overridden Functions

    public override func setup() {
        super.setup()

        self.heightConstraint = self.setHeightConstraintValue(to: Self.DEFAULT_HEIGHT)

        self.setCornerRadius(to: Self.DEFAULT_HEIGHT / 2)
            .setBackgroundColor(to: Colors.fillSecondary)
            .add(self.fill)

        self.fillWidthConstraint = self.fill.setWidthConstraintValue(to: 0.0)

        self.fill
            .setCornerRadius(to: Self.DEFAULT_HEIGHT / 2)
            .setBackgroundColor(to: Colors.accent)
            .constrainLeft()
            .constrainVertical()
    }

    // MARK: Functions

    @discardableResult
    public func setProgress(to progress: Double, animated: Bool = false) -> Self {
        let clamped = min(max(progress, 0.0), 1.0)
        self.fillWidthConstraint.isActive = false
        self.fillWidthConstraint = self.fill.setWidthConstraintValue(proportion: clamped)
        if animated {
            UIView.animate(
                withDuration: 0.2,
                delay: 0,
                options: [.curveEaseOut, .beginFromCurrentState],
                animations: { [weak self] in
                    self?.layoutIfNeeded()
                },
                completion: nil
            )
        }
        return self
    }

    @discardableResult
    public func setHeight(to height: Double) -> Self {
        assert(height.isGreaterThanZero(), "Expected positive progress bar height")
        self.heightConstraint.constant = max(height, 0.0)
        self.setCornerRadius(to: height / 2)
        self.fill.setCornerRadius(to: height / 2)
        return self
    }
}
