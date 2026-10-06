//
//  NavBar.swift
//  https://github.com/Andre-Pham/Zilliax
//
//  Created by Andre Pham.
//

import UIKit

public class NavBar: View {
    // MARK: Nested Types

    public enum ItemAlignment {
        case left
        case right
    }

    // MARK: Properties

    private let stack = VStack()
    private let title = Text()
    private var leftIconButton: IconButton? = nil
    private var rightIconButton: IconButton? = nil

    // MARK: Overridden Functions

    public override func setup() {
        super.setup()

        self.add(self.stack)

        self.stack
            .constrainAllSides(layoutGuide: .view)
            .appendGap(size: 20)
            .append(self.title)
            .appendGap(size: 16)

        self.title
            .setFont(to: UIFont.systemFont(ofSize: 22, weight: .semibold))
            .toggleWordWrapping(to: false)
            .setHeightConstraint(to: ceil(self.title.font.lineHeight))
            .setTextColor(to: Colors.textDark)
    }

    // MARK: Functions

    @discardableResult
    public func setTitle(to title: String) -> Self {
        self.title.setText(to: title)
        return self
    }

    @discardableResult
    public func addIconButton(alignment: ItemAlignment, icon: Icon.Config, onTap: (() -> Void)? = nil) -> Self {
        let iconButton = IconButton()
            .addAsSubview(of: self)
            .setSizeConstraint(to: 36)
            .constrainTop(padding: 15)
            .setIcon(to: .init(
                systemName: "questionmark.circle.fill",
                size: 20,
                weight: .medium,
                color: Colors.textDark
            ))
            .setIcon(to: icon)
            .setOnTap(onTap)

        switch alignment {
        case .left:
            self.leftIconButton?.remove()
            iconButton.constrainLeft(padding: 15)
            self.leftIconButton = iconButton
        case .right:
            self.rightIconButton?.remove()
            iconButton.constrainRight(padding: 15)
            self.rightIconButton = iconButton
        }
        return self
    }

    @discardableResult
    public func configureIconButton(alignment: ItemAlignment, _ callback: (_ iconButton: IconButton?) -> Void) -> Self {
        switch alignment {
        case .left:
            callback(self.leftIconButton)
        case .right:
            callback(self.rightIconButton)
        }
        return self
    }
}
