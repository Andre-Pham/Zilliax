//
//  TabBarButton.swift
//  https://github.com/Andre-Pham/Zilliax
//
//  Created by Andre Pham.
//

import UIKit

public class TabBarButton: View {
    // MARK: Properties

    private let button = Button()
    private let icon = Icon()
    private let label = Text()
    private var onTap: (() -> Void)? = nil

    // MARK: Overridden Functions

    public override func setup() {
        super.setup()

        self.setBackgroundColor(to: Colors.fillSecondary)

        self.button
            .addAsSubview(of: self)
            .constrainAllSides()
            .setOnRelease({
                self.onTap?()
            })

        self.icon
            .addAsSubview(of: self)
            .constrainCenterHorizontal()
            .constrainTop(padding: 12)
            .setSize(to: 22)
            .setColor(to: Colors.textDark)
            .setWeight(to: .light)
            .setSizeConstraint(to: 26)

        self.label
            .addAsSubview(of: self.icon)
            .setFont(to: UIFont.systemFont(ofSize: 10, weight: .medium))
            .setTextColor(to: Colors.textDark)
            .setSize(to: 10)
            .setTextAlignment(to: .center)
            .setHeightConstraint(to: 20)
            .constrainCenterVertical()
            .constrainCenterHorizontal()
            .setTransformation(to: CGAffineTransform(translationX: 0, y: 24))
    }

    // MARK: Functions

    @discardableResult
    public func setIcon(to config: Icon.Config) -> Self {
        self.icon.setIcon(to: config)
        return self
    }

    @discardableResult
    public func setLabel(to label: String) -> Self {
        self.label.setText(to: label)
        return self
    }

    @discardableResult
    public func setColor(to color: UIColor) -> Self {
        self.setBackgroundColor(to: color)
        return self
    }

    @discardableResult
    public func setOnTap(_ callback: (() -> Void)?) -> Self {
        self.onTap = callback
        return self
    }
}
