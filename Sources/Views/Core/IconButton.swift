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
    private let icon = Icon()
    private var onTap: (() -> Void)? = nil

    // MARK: Overridden Functions

    public override func setup() {
        super.setup()

        self.add(self.button)
            .add(self.icon)

        self.button
            .constrainAllSides(respectSafeArea: false)
            .animateOnPress(self)

        self.icon
            .constrainCenter(respectSafeArea: false)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        self.setCornerRadius(to: min(self.bounds.width, self.bounds.height) / 2.0)
    }

    // MARK: Functions

    @discardableResult
    public func setIcon(to config: Icon.Config) -> Self {
        self.icon.setIcon(to: config)
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
}
