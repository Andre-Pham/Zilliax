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
    private let decreasePanGesture = PanGesture()
    private let increasePanGesture = PanGesture()
    private var textMinWidthConstraint: NSLayoutConstraint? = nil
    private let decreaseIcon = Icon.Config(systemName: "minus", size: 17, weight: .bold)
    private let retreatIcon = Icon.Config(systemName: "chevron.left.2", size: 17, weight: .bold)
    private let increaseIcon = Icon.Config(systemName: "plus", size: 17, weight: .bold)
    private let advanceIcon = Icon.Config(systemName: "chevron.right.2", size: 17, weight: .bold)
    private var value = 0
    private var minValue: Int? = nil
    private var maxValue: Int? = nil
    private var decreaseHoldTimer: Timer? = nil
    private var decreaseHoldTranslation: CGPoint? = nil
    private var increaseHoldTimer: Timer? = nil
    private var increaseHoldTranslation: CGPoint? = nil

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
            .setIcon(to: self.decreaseIcon)
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
            .setIcon(to: self.increaseIcon)
            .setSizeConstraint(to: Self.HEIGHT - Self.INNER_PADDING * 2)
            .setBackgroundColor(to: Colors.fillForeground)
            .setOnTap({ [weak self] in
                guard let self = self else {
                    return
                }
                self.setValue(to: self.value + 1)
            })

        self.decreasePanGesture
            .setCancelsTouchesInView(to: false)
            .addGestureRecognizer(to: self.decreaseButton)
            .setOnGesture({ gesture in
                self.decreaseHoldTranslation = gesture.translation(in: self.decreaseButton)
                if self.decreaseHoldTimer == nil && (gesture.state == .began || gesture.state == .changed) {
                    self.decreaseHoldTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                        guard let self = self else {
                            return
                        }
                        if let decreaseHoldTranslation, decreaseHoldTranslation.x.isLess(than: -35.0) {
                            self.setValue(to: self.value - 1)
                            self.decreaseButton.setIcon(to: self.retreatIcon)
                        } else {
                            self.decreaseButton.setIcon(to: self.decreaseIcon)
                        }
                    }
                } else if gesture.state == .ended || gesture.state == .cancelled || gesture.state == .failed {
                    self.decreaseHoldTimer?.invalidate()
                    self.decreaseHoldTimer = nil
                    self.decreaseHoldTranslation = nil
                    self.decreaseButton.setIcon(to: self.decreaseIcon)
                }
            })

        self.increasePanGesture
            .setCancelsTouchesInView(to: false)
            .addGestureRecognizer(to: self.increaseButton)
            .setOnGesture({ gesture in
                self.increaseHoldTranslation = gesture.translation(in: self.increaseButton)
                if self.increaseHoldTimer == nil && (gesture.state == .began || gesture.state == .changed) {
                    self.increaseHoldTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                        guard let self = self else {
                            return
                        }
                        if let increaseHoldTranslation, increaseHoldTranslation.x.isGreater(than: 35.0) {
                            self.setValue(to: self.value + 1)
                            self.increaseButton.setIcon(to: self.advanceIcon)
                        } else {
                            self.increaseButton.setIcon(to: self.increaseIcon)
                        }
                    }
                } else if gesture.state == .ended || gesture.state == .cancelled || gesture.state == .failed {
                    self.increaseHoldTimer?.invalidate()
                    self.increaseHoldTimer = nil
                    self.increaseHoldTranslation = nil
                    self.increaseButton.setIcon(to: self.increaseIcon)
                }
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
