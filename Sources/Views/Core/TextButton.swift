//
//  TextButton.swift
//  https://github.com/Andre-Pham/Zilliax
//
//  Created by Andre Pham.
//

import UIKit

public class TextButton: View {
    // MARK: Nested Types

    public enum IconAlignment {
        case left
        case right
    }

    // MARK: Properties

    private let contentStack = HStack()
    private let button = Button()
    private let spinner = IconSpinner()
    private let icon = IconImage()
    private let label = Text()
    private var onTap: (() -> Void)? = nil
    private var iconAdded = false
    private var iconAlignment = IconAlignment.left
    private var labelAdded = false
    private var isLoading = false

    // MARK: Computed Properties

    public var isDisabled: Bool {
        return self.button.isDisabled
    }

    // MARK: Overridden Functions

    public override func setup() {
        super.setup()

        self.add(self.contentStack)
            .add(self.button)

        self.contentStack
            .constrainAllSides(respectSafeArea: false)
            .setSpacing(to: 8)

        self.button
            .constrainCenter(respectSafeArea: false)
            .matchWidthConstraint(adjust: 12, respectSafeArea: false)
            .matchHeightConstraint(adjust: 12, respectSafeArea: false)
            .animateOnPress(self)

        self.icon
            .setIcon(to: .init(size: 14, weight: .bold, color: Colors.textSecondary))

        self.spinner
            .setIcon(to: self.icon.config.with(systemName: "progress.indicator"))

        self.label
            .setFont(to: UIFont.systemFont(ofSize: 15, weight: .semibold))
            .setTextColor(to: Colors.textSecondary)
            .setTextAlignment(to: .center)
    }

    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if super.point(inside: point, with: event) {
            return true
        }
        return self.button.frame.contains(point)
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
        self.spinner.setIcon(to: config.with(systemName: self.spinner.config.systemName))
        self.icon.setHidden(to: self.isLoading && alignment == .left)
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
    public func setForegroundColor(to color: UIColor) -> Self {
        self.icon.setColor(to: color)
        self.spinner.setColor(to: color)
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

    @discardableResult
    public func setLoading(to state: Bool) -> Self {
        guard self.isLoading != state else {
            return self
        }
        self.isLoading = state
        self.setDisabled(to: state)
        if state {
            if !self.spinner.hasSuperView {
                self.contentStack.insert(self.spinner, at: 0)
            }
            self.spinner.startAnimating()
            if self.iconAdded, self.iconAlignment == .left {
                self.icon.setHidden(to: true)
            }
        } else {
            if self.spinner.hasSuperView {
                self.contentStack.pop(self.spinner)
            }
            self.spinner.stopAnimating()
            if self.iconAdded, self.iconAlignment == .left {
                self.icon.setHidden(to: false)
            }
        }
        self.invalidateIntrinsicContentSize()
        return self
    }
}
