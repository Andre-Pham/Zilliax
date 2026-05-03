//
//  Pill.swift
//  https://github.com/Andre-Pham/Zilliax
//
//  Created by Andre Pham.
//

import UIKit

public class Pill: View {
    // MARK: Nested Types

    public enum IconAlignment {
        case left
        case right
    }

    // MARK: Static Properties

    private static let HEIGHT = 36.0

    // MARK: Overridden Properties

    public override var intrinsicContentSize: CGSize {
        let contentSize = self.contentStack.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        return CGSize(width: contentSize.width + 36, height: Self.HEIGHT)
    }

    // MARK: Properties

    private let contentStack = HStack()
    private let icon = IconImage()
    private let label = Text()
    private var iconAdded = false
    private var iconAlignment = IconAlignment.left
    private var labelAdded = false

    // MARK: Overridden Functions

    public override func setup() {
        super.setup()

        self.setHeightConstraint(to: Self.HEIGHT)
            .setBackgroundColor(to: Colors.fillSecondary)
            .setCornerRadius(to: Self.HEIGHT / 2)
            .add(self.contentStack)

        self.contentStack
            .constrainVertical(layoutGuide: .view)
            .constrainCenterHorizontal(layoutGuide: .view)
            .constrainMaxHorizontal(padding: 18)
            .setSpacing(to: 8)

        self.icon
            .setIcon(to: .init(size: 14, weight: .bold, color: Colors.textSecondary))

        self.label
            .setFont(to: UIFont.systemFont(ofSize: 15, weight: .semibold))
            .setTextColor(to: Colors.textSecondary)
            .setTextAlignment(to: .center)
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
        self.invalidateIntrinsicContentSize()
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
        self.invalidateIntrinsicContentSize()
        return self
    }

    @discardableResult
    public func setFont(to font: UIFont) -> Self {
        self.label.setFont(to: font)
        self.invalidateIntrinsicContentSize()
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
}
