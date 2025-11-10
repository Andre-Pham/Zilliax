//
//  OpenView.swift
//  Demo
//

import UIKit

public class OpenView: View {
    // MARK: Properties

    private let stack = HStack()
    private let text = Text()
    private let icon = Icon()
    private let button = Button()

    // MARK: Overridden Functions

    public override func setup() {
        super.setup()

        self.add(self.stack)
            .add(self.button)

        self.stack
            .constrainAllSides(padding: 12)
            .append(self.text)
            .appendGap(size: 8)
            .append(self.icon)

        self.button
            .constrainAllSides(respectSafeArea: false)
            .animateOnPress(self)

        self.icon
            .setSymbol(systemName: "chevron.right")
            .setWeight(to: .bold)
            .setSize(to: 12)
            .setSizeConstraint(to: 12)
    }

    // MARK: Functions

    @discardableResult
    public func setText(to text: String) -> Self {
        self.text.setText(to: text)
        return self
    }

    @discardableResult
    public func setOnTap(_ callback: (() -> Void)?) -> Self {
        self.button.setOnRelease(callback)
        return self
    }
}
