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
    private static let TEXT_PAN_STEP: CGFloat = 5.0

    // MARK: Properties

    private let stack = HStack()
    private let text = Text()
    private let decreaseButton = IconButton()
    private let increaseButton = IconButton()
    private let decreasePanGesture = PanGesture()
    private let increasePanGesture = PanGesture()
    private let textPanGesture = PanGesture()
    private var textMinWidthConstraint: NSLayoutConstraint? = nil
    private let decreaseIcon = Icon.Config(systemName: "minus", size: 17, weight: .bold)
    private let retreatIcon = Icon.Config(systemName: "chevron.left.2", size: 17, weight: .bold)
    private let increaseIcon = Icon.Config(systemName: "plus", size: 17, weight: .bold)
    private let advanceIcon = Icon.Config(systemName: "chevron.right.2", size: 17, weight: .bold)
    private var isShowingRetreatIcon: Bool? = nil
    private var isShowingAdvanceIcon: Bool? = nil
    private var decreaseIconAnimationID = 0
    private var increaseIconAnimationID = 0
    private var value = 0
    private var minValue: Int? = nil
    private var maxValue: Int? = nil
    private var decreaseHoldTimer: Timer? = nil
    private var decreaseHoldTranslation: CGPoint? = nil
    private var increaseHoldTimer: Timer? = nil
    private var increaseHoldTranslation: CGPoint? = nil
    private var isIncreasing = false
    private var isDecreasing = false
    private var textPanStartValue = 0

    // MARK: Overridden Functions

    public override func setup() {
        super.setup()

        self.setHeightConstraint(to: Self.HEIGHT)
            .setCornerRadius(to: Self.HEIGHT / 2)
            .setBackgroundColor(to: Colors.fillSecondary)
            .add(self.stack)
            .add(self.textPanGesture)

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
        self.setDecreaseButtonIcon(isRetreat: false, animated: false)

        self.text
            .setTextAlignment(to: .center)
        self.textMinWidthConstraint = self.text.setMinWidthConstraintValue(to: self.getMinWidth(for: self.value))

        self.increaseButton
            .setSizeConstraint(to: Self.HEIGHT - Self.INNER_PADDING * 2)
            .setBackgroundColor(to: Colors.fillForeground)
            .setOnTap({ [weak self] in
                guard let self = self else {
                    return
                }
                self.setValue(to: self.value + 1)
            })
        self.setIncreaseButtonIcon(isAdvance: false, animated: false)

        self.decreasePanGesture
            .setCancelsTouchesInView(to: false)
            .addGestureRecognizer(to: self.decreaseButton)
            .setOnGesture({ gesture in
                self.decreaseHoldTranslation = gesture.translation(in: self.decreaseButton)
                if self.decreaseHoldTimer == nil && (gesture.state == .began || gesture.state == .changed) {
                    self.decreaseHoldTimer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { [weak self] _ in
                        guard let self = self else {
                            return
                        }
                        if let decreaseHoldTranslation {
                            if decreaseHoldTranslation.x.isLess(than: -35.0) {
                                self.isDecreasing = true
                            } else if decreaseHoldTranslation.x.isGreater(than: -20.0) {
                                self.isDecreasing = false
                            }
                        }
                        if self.isDecreasing {
                            self.setValue(to: self.value - 1)
                            self.setDecreaseButtonIcon(isRetreat: true, animated: true)
                        } else {
                            self.setDecreaseButtonIcon(isRetreat: false, animated: true)
                        }
                    }
                } else if gesture.state == .ended || gesture.state == .cancelled || gesture.state == .failed {
                    self.decreaseHoldTimer?.invalidate()
                    self.decreaseHoldTimer = nil
                    self.decreaseHoldTranslation = nil
                    self.isDecreasing = false
                    self.setDecreaseButtonIcon(isRetreat: false, animated: true, force: true)
                }
            })

        self.increasePanGesture
            .setCancelsTouchesInView(to: false)
            .addGestureRecognizer(to: self.increaseButton)
            .setOnGesture({ gesture in
                self.increaseHoldTranslation = gesture.translation(in: self.increaseButton)
                if self.increaseHoldTimer == nil && (gesture.state == .began || gesture.state == .changed) {
                    self.increaseHoldTimer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { [weak self] _ in
                        guard let self = self else {
                            return
                        }
                        if let increaseHoldTranslation {
                            if increaseHoldTranslation.x.isGreater(than: 35.0) {
                                self.isIncreasing = true
                            } else if increaseHoldTranslation.x.isLess(than: 20.0) {
                                self.isIncreasing = false
                            }
                        }
                        if self.isIncreasing {
                            self.setValue(to: self.value + 1)
                            self.setIncreaseButtonIcon(isAdvance: true, animated: true)
                        } else {
                            self.setIncreaseButtonIcon(isAdvance: false, animated: true)
                        }
                    }
                } else if gesture.state == .ended || gesture.state == .cancelled || gesture.state == .failed {
                    self.increaseHoldTimer?.invalidate()
                    self.increaseHoldTimer = nil
                    self.increaseHoldTranslation = nil
                    self.setIncreaseButtonIcon(isAdvance: false, animated: true, force: true)
                }
            })

        self.textPanGesture
            .setCancelsTouchesInView(to: false)
            .constrainToRightSide(of: self.decreaseButton)
            .constrainToLeftSide(of: self.increaseButton)
            .constrainVertical()
            .setOnGesture({ [weak self] gesture in
                guard let self = self else {
                    return
                }
                switch gesture.state {
                case .began:
                    self.textPanStartValue = self.value
                    fallthrough
                case .changed:
                    let translation = gesture.translation(in: self)
                    let delta = Int((translation.x / Self.TEXT_PAN_STEP).rounded(.towardZero))
                    let newValue = self.textPanStartValue + delta
                    if newValue != self.value {
                        self.setValue(to: newValue)
                    }
                case .ended, .cancelled, .failed:
                    self.textPanStartValue = self.value
                default:
                    break
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
        let disableDecrease = self.minValue.map({ self.value <= $0 }) ?? false
        if disableDecrease != self.decreaseButton.isDisabled {
            self.decreaseButton.setDisabled(to: disableDecrease)
        }
        let disableIncrease = self.minValue.map({ self.value >= $0 }) ?? false
        if disableIncrease != self.increaseButton.isDisabled {
            self.increaseButton.setDisabled(to: disableIncrease)
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

    private func setDecreaseButtonIcon(isRetreat: Bool, animated: Bool, force: Bool = false) {
        guard force || self.isShowingRetreatIcon != isRetreat else {
            return
        }
        self.isShowingRetreatIcon = isRetreat
        self.decreaseIconAnimationID += 1
        let animationID = self.decreaseIconAnimationID
        self.decreaseButton.layer.removeAllAnimations()
        self.decreaseButton.transform = .identity
        let icon = isRetreat ? self.retreatIcon : self.decreaseIcon
        let iconUpdate = {
            guard animationID == self.decreaseIconAnimationID else {
                return
            }
            _ = self.decreaseButton.setIcon(to: icon)
        }
        if animated {
            UIView.animate(
                withDuration: 0.1,
                delay: 0.0,
                options: [.curveEaseIn],
                animations: {
                    self.decreaseButton.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
                },
                completion: { _ in
                    iconUpdate()
                    UIView.animate(
                        withDuration: 0.1,
                        delay: 0.0,
                        options: [.curveEaseOut],
                        animations: {
                            self.decreaseButton.transform = .identity
                        },
                        completion: nil
                    )
                }
            )
        } else {
            iconUpdate()
        }
    }

    private func setIncreaseButtonIcon(isAdvance: Bool, animated: Bool, force: Bool = false) {
        guard force || self.isShowingAdvanceIcon != isAdvance else {
            return
        }
        self.isShowingAdvanceIcon = isAdvance
        self.increaseIconAnimationID += 1
        let animationID = self.increaseIconAnimationID
        self.increaseButton.layer.removeAllAnimations()
        self.increaseButton.transform = .identity
        let icon = isAdvance ? self.advanceIcon : self.increaseIcon
        let iconUpdate = {
            guard animationID == self.increaseIconAnimationID else {
                return
            }
            _ = self.increaseButton.setIcon(to: icon)
        }
        if animated {
            UIView.animate(
                withDuration: 0.1,
                delay: 0.0,
                options: [.curveEaseIn],
                animations: {
                    self.increaseButton.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
                },
                completion: { _ in
                    iconUpdate()
                    UIView.animate(
                        withDuration: 0.1,
                        delay: 0.0,
                        options: [.curveEaseOut],
                        animations: {
                            self.increaseButton.transform = .identity
                        },
                        completion: nil
                    )
                }
            )
        } else {
            iconUpdate()
        }
    }
}
