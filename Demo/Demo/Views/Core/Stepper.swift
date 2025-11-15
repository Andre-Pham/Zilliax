//
//  Stepper.swift
//  https://github.com/Andre-Pham/Zilliax
//
//  Created by Andre Pham.
//

import UIKit

public class Stepper: View {
    // MARK: Static Properties

    private static let HEIGHT = 50.0
    private static let INNER_PADDING = 5.0

    // MARK: Properties

    private let stack = HStack()
    private let text = Text()
    private let decreaseButton = IconButton()
    private let increaseButton = IconButton()
    private var textMinWidthConstraint: NSLayoutConstraint? = nil
    private var value = 0
    private var minValue: Int? = nil
    private var maxValue: Int? = nil

    // MARK: Overridden Functions

    public override func setup() {
        super.setup()

        self.setHeightConstraint(to: Self.HEIGHT)
            .setCornerRadius(to: Self.HEIGHT / 2)
            .add(self.stack)
            .setBackgroundColor(to: Colors.fillSecondary)

        self.stack
            .constrainAllSides(padding: Self.INNER_PADDING)
            .setSpacing(to: 20)
            .append(self.decreaseButton)
            .append(self.text)
            .append(self.increaseButton)

        self.decreaseButton
            .setIcon(to: .init(systemName: "minus", size: 17, weight: .bold))
            .setSizeConstraint(to: Self.HEIGHT - Self.INNER_PADDING * 2)
            .setBackgroundColor(to: Colors.fillForeground)
            .setOnTap({ [weak self] in
                guard let self = self else {
                    return
                }
                self.setValue(to: self.value - 1)
            })

        self.text
            .setTextAlignment(to: .center)

        self.textMinWidthConstraint = self.text.setMinWidthConstraintValue(to: self.getMinWidth(for: self.value))

        self.increaseButton
            .setIcon(to: .init(systemName: "plus", size: 17, weight: .bold))
            .setSizeConstraint(to: Self.HEIGHT - Self.INNER_PADDING * 2)
            .setBackgroundColor(to: Colors.fillForeground)
            .setOnTap({ [weak self] in
                guard let self = self else {
                    return
                }
                self.setValue(to: self.value + 1)
            })

        self.update()
    }

    // MARK: Functions

    @discardableResult
    public func setValue(to value: Int) -> Self {
        var clamped = value
        if let minValue = self.minValue {
            clamped = max(clamped, minValue)
        }
        if let maxValue = self.maxValue {
            clamped = min(clamped, maxValue)
        }
        self.value = clamped
        self.update()
        return self
    }

    @discardableResult
    public func setMin(to minValue: Int?) -> Self {
        self.minValue = minValue
        if let minValue {
            self.value = max(minValue, self.value)
        }
        self.update()
        return self
    }

    @discardableResult
    public func setMax(to maxValue: Int?) -> Self {
        self.maxValue = maxValue
        if let maxValue {
            self.value = min(maxValue, self.value)
        }
        self.update()
        return self
    }

    private func update() {
        self.text.setText(to: String(self.value))
        self.textMinWidthConstraint?.constant = self.getMinWidth(for: self.value)
        if let minValue {
            self.decreaseButton.setDisabled(to: self.value <= minValue)
        } else {
            self.decreaseButton.setDisabled(to: false)
        }
        if let maxValue {
            self.increaseButton.setDisabled(to: self.value >= maxValue)
        } else {
            self.increaseButton.setDisabled(to: false)
        }
    }

    private func getMinWidth(for value: Int) -> CGFloat {
        let digitCount = max(String(value.magnitude).count, 1)
        let digitMinWidth = CGFloat(digitCount * 16)
        if value < 0 {
            return digitMinWidth + 12
        }
        return digitMinWidth
    }
}
