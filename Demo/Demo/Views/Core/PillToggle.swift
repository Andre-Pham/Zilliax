//
//  PillToggle.swift
//  https://github.com/Andre-Pham/Zilliax
//
//  Created by Andre Pham.
//

import UIKit

public class PillToggle: View, UIGestureRecognizerDelegate {
    // MARK: Nested Types

    public enum IconAlignment {
        case left
        case right
    }

    // MARK: Static Properties

    private static let HEIGHT = 36.0

    // MARK: Properties

    public private(set) var isOn = false

    private let contentStack = HStack()
    private let button = Button()
    private let icon = IconImage()
    private let label = Text()
    private let pressGesture = LongPressGesture()
    private var onToggle: ((_ isOn: Bool) -> Void)? = nil
    private var iconAdded = false
    private var iconAlignment = IconAlignment.left
    private var labelAdded = false
    private var isLocked = false
    private var onColors: (background: UIColor, foreground: UIColor) = (Colors.fillPrimary, Colors.textPrimary)
    private var offColors: (background: UIColor, foreground: UIColor) = (Colors.fillSecondary, Colors.textSecondary)

    // MARK: Computed Properties

    public var isOff: Bool {
        return !self.isOn
    }

    public var isDisabled: Bool {
        return self.button.isDisabled
    }

    // MARK: Overridden Functions

    public override func setup() {
        super.setup()

        self.setHeightConstraint(to: Self.HEIGHT)
            .setBackgroundColor(to: Colors.fillSecondary)
            .setCornerRadius(to: Self.HEIGHT / 2)
            .add(self.contentStack)
            .add(self.button)

        self.contentStack
            .constrainVertical(respectSafeArea: false)
            .constrainCenterHorizontal(respectSafeArea: false)
            .setSpacing(to: 8)
            .constrainMaxLeft(padding: 18)
            .constrainMaxRight(padding: 18)

        self.button
            .constrainAllSides(respectSafeArea: false)
            .setOnRelease({ [weak self] in
                self?.toggle()
            })
            .animateOnPress(
                self,
                onPress: { view in
                    view.setTransformation(to: CGAffineTransform(scaleX: 0.95, y: 0.95), animated: true)
                },
                onRelease: { view in
                    view.setTransformation(to: .identity, animated: true)
                }
            )

        self.pressGesture
            .setMinimumPressDuration(to: 0)
            .setCancelsTouchesInView(to: false)
            .setDelaysTouchesBegan(to: false)
            .setDelegate(to: self)
            .setOnGesture({ [weak self] gesture in
                guard let self = self else {
                    return
                }
                // Allow this view to animate within a scroll view
                switch gesture.state {
                case .began:
                    self.setTransformation(to: CGAffineTransform(scaleX: 0.95, y: 0.95), animated: true)
                case .ended, .cancelled, .failed:
                    self.setTransformation(to: .identity, animated: true)
                default:
                    break
                }
            })
            .addGestureRecognizer(to: self)

        self.icon
            .setIcon(to: .init(size: 14, weight: .bold, color: Colors.textSecondary))

        self.label
            .setFont(to: UIFont.systemFont(ofSize: 15, weight: .semibold))
            .setTextColor(to: Colors.textSecondary)
            .setTextAlignment(to: .center)
    }

    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        // Allow gestures to be recognised whilst panning in a scroll view so this may still animate
        return true
    }

    // MARK: Functions

    @discardableResult
    public func setIcon(to config: IconImage.Config, alignment: IconAlignment = .left) -> Self {
        if self.iconAdded, self.iconAlignment != alignment {
            self.contentStack.pop(self.icon)
            self.iconAdded = false
        }
        if !self.iconAdded {
            if self.labelAdded, alignment == .left {
                self.contentStack.insert(self.icon, at: self.contentStack.viewCount - 1)
            } else {
                self.contentStack.append(self.icon)
            }
            self.iconAdded = true
        }
        self.iconAlignment = alignment
        self.icon.setIcon(to: config)
        return self
    }

    @discardableResult
    public func setLabel(to label: String) -> Self {
        if !self.labelAdded {
            if self.iconAdded, self.iconAlignment == .right {
                self.contentStack.insert(self.label, at: self.contentStack.viewCount - 1)
            } else {
                self.contentStack.append(self.label)
            }
            self.labelAdded = true
        }
        self.label.setText(to: label)
        return self
    }

    @discardableResult
    public func setFont(to font: UIFont) -> Self {
        self.label.setFont(to: font)
        return self
    }

    @discardableResult
    public func setColors(
        on: (background: UIColor, foreground: UIColor),
        off: (background: UIColor, foreground: UIColor)
    ) -> Self {
        self.onColors = on
        self.offColors = off
        self.updateColors()
        return self
    }

    @discardableResult
    public func setState(isOn: Bool, trigger: Bool = false) -> Self {
        guard self.isOn != isOn else {
            return self
        }
        self.isOn = isOn
        self.updateColors()
        if trigger {
            self.onToggle?(self.isOn)
        }
        return self
    }

    @discardableResult
    public func setOnToggle(_ callback: ((_ isOn: Bool) -> Void)?) -> Self {
        self.onToggle = callback
        return self
    }

    @discardableResult
    public func setDisabled(to state: Bool) -> Self {
        self.button.setDisabled(to: state)
        if state {
            self.setDisabledOpacity()
        } else {
            self.setOpacity(to: 1.0)
        }
        return self
    }

    @discardableResult
    public func setLocked(to state: Bool) -> Self {
        self.isLocked = state
        return self
    }

    private func toggle() {
        guard !self.isLocked else {
            return
        }
        self.isOn.toggle()
        self.updateColors()
        self.onToggle?(self.isOn)
    }

    private func updateColors() {
        let backgroundColor = self.isOn ? self.onColors.background : self.offColors.background
        let foregroundColor = self.isOn ? self.onColors.foreground : self.offColors.foreground
        self.setBackgroundColor(to: backgroundColor)
        self.icon.setColor(to: foregroundColor)
        self.label.setTextColor(to: foregroundColor)
    }
}
