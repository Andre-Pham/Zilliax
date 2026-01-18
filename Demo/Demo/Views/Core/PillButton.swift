//
//  PillButton.swift
//  https://github.com/Andre-Pham/Zilliax
//
//  Created by Andre Pham.
//

import UIKit

public class PillButton: View {
    // MARK: Static Properties

    private static let HEIGHT = 42.0

    // MARK: Properties

    private let contentStack = HStack()
    private let button = Button()
    private let icon = IconImage()
    private let label = Text()
    private var onTap: (() -> Void)? = nil
    private var iconAdded = false
    private var labelAdded = false

    // MARK: Computed Properties

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
            .animateOnPress(self)

        self.icon
            .setIcon(to: .init(size: 14, weight: .bold, color: Colors.textSecondary))

        self.label
            .setFont(to: UIFont.systemFont(ofSize: 15, weight: .semibold))
            .setTextColor(to: Colors.textSecondary)
            .setTextAlignment(to: .center)
    }

    // MARK: Functions

    @discardableResult
    public func setIcon(to config: IconImage.Config) -> Self {
        if !self.iconAdded {
            if self.labelAdded {
                self.contentStack.insert(self.icon, at: self.contentStack.viewCount - 1)
            } else {
                self.contentStack.append(self.icon)
            }
            self.iconAdded = true
        }
        self.icon.setIcon(to: config)
        return self
    }

    @discardableResult
    public func setLabel(to label: String) -> Self {
        if !self.labelAdded {
            self.contentStack.append(self.label)
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
    public func setColor(to color: UIColor) -> Self {
        self.setBackgroundColor(to: color)
        return self
    }

    @discardableResult
    public func setForegroundColor(to color: UIColor) -> Self {
        self.icon.setColor(to: color)
        self.label.setTextColor(to: color)
        return self
    }

    @discardableResult
    public func setOnTap(_ callback: (() -> Void)?) -> Self {
        self.button.setOnRelease(callback)
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
}
