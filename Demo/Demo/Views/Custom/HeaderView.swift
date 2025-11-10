//
//  HeaderView.swift
//  Demo
//

import UIKit

public class HeaderView: View {
    // MARK: Properties

    private let titleText = Text()
    private let descriptionText = Text()
    private let backButton = IconButton()

    // MARK: Overridden Functions

    public override func setup() {
        super.setup()

        self.add(self.titleText)
            .add(self.descriptionText)
            .add(self.backButton)

        self.titleText
            .constrainCenterHorizontal()
            .constrainTop(padding: 24)
            .setHeightConstraint(to: 36)
            .setSize(to: 20)

        self.descriptionText
            .constrainTop(padding: 88)
            .matchWidthConstrainCenter(maxWidth: 600)
            .setTextColor(to: Colors.textMuted)
            .setTextAlignment(to: .center)
            .constrainBottom()

        self.backButton
            .constrainTop(padding: 24)
            .constrainLeft()
            .setIcon(to: Icon.Config(
                systemName: "chevron.left",
                size: 20,
                weight: .medium,
                color: Colors.textDark
            ))
            .setSizeConstraint(to: 36)
    }

    // MARK: Functions

    @discardableResult
    public func setTitle(to title: String) -> Self {
        self.titleText.setText(to: title)
        return self
    }

    @discardableResult
    public func setDescription(to description: String) -> Self {
        self.descriptionText.setText(to: description)
        return self
    }

    @discardableResult
    public func setOnBack(_ callback: (() -> Void)?) -> Self {
        self.backButton.setOnTap(callback)
        return self
    }
}
