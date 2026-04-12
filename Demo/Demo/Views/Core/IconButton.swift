//
//  IconButton.swift
//  https://github.com/Andre-Pham/Zilliax
//
//  Created by Andre Pham.
//

import UIKit

public class IconButton: View {
    // MARK: Properties

    private let button = Button()
    private let spinner = IconSpinner()
    private let icon = Icon()
    private var onTap: (() -> Void)? = nil
    private var isLoading = false

    // MARK: Computed Properties

    public var isDisabled: Bool {
        return self.button.isDisabled
    }

    // MARK: Overridden Functions

    public override func setup() {
        super.setup()

        self.add(self.button)
            .add(self.spinner)
            .add(self.icon)

        self.button
            .constrainAllSides(layoutGuide: .view)
            .animateOnPress(self)

        self.icon
            .constrainCenter(layoutGuide: .view)

        self.spinner
            .constrainCenter(layoutGuide: .view)
            .setHidden(to: true)
            .setIcon(to: self.icon.config.with(systemName: "progress.indicator"))
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        self.setCornerRadius(to: min(self.bounds.width, self.bounds.height) / 2.0)
    }

    // MARK: Functions

    @discardableResult
    public func setIcon(to config: Icon.Config) -> Self {
        self.icon.setIcon(to: config)
        self.spinner.setIcon(to: config.with(systemName: self.spinner.config.systemName))
        self.icon.setHidden(to: self.isLoading)
        return self
    }

    @discardableResult
    public func setColor(to color: UIColor) -> Self {
        self.setBackgroundColor(to: color)
        return self
    }

    @discardableResult
    public func setOnTap(_ callback: (() -> Void)?) -> Self {
        self.button.setOnRelease(callback)
        return self
    }

    @discardableResult
    public func setMenu(to menu: UIMenu?) -> Self {
        self.button
            .setMenu(to: menu)
            .setMenuAnimations(
                onOpen: {
                    self.setPressedOpacity()
                },
                onClose: {
                    self.setOpacity(to: 1.0)
                }
            )
        return self
    }

    @discardableResult
    public func removeMenu() -> Self {
        self.button.removeMenu()
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
        self.spinner.setHidden(to: !state)
        if state {
            self.spinner.startAnimating()
            self.icon.setHidden(to: true)
        } else {
            self.spinner.stopAnimating()
            self.icon.setHidden(to: false)
        }
        return self
    }
}
