//
//  Details.swift
//  https://github.com/Andre-Pham/Zilliax
//
//  Created by Andre Pham.
//

import UIKit

public class Details: View {
    // MARK: Properties

    private let stack = VStack()

    // MARK: Overridden Functions

    public override func setup() {
        super.setup()

        self.add(self.stack)

        self.stack
            .constrainAllSides(respectSafeArea: false)
            .setSpacing(to: 12)
            .setAlignment(to: .fill)
    }

    // MARK: Functions

    @discardableResult
    public func addRow(title: String, value: String) -> Self {
        let titleText = Text()
            .setText(to: title)
            .setFont(to: UIFont.systemFont(ofSize: 17, weight: .medium))
            .setTextColor(to: Colors.textMuted)
        let valueText = Text()
            .setText(to: value)
            .setFont(to: UIFont.systemFont(ofSize: 17, weight: .semibold))
            .setTextAlignment(to: .right)
        let row = HStack()
            .setAlignment(to: .firstBaseline)
            .append(titleText)
            .appendGap(size: 12)
            .append(valueText)
        self.stack.append(row)
        return self
    }

    @discardableResult
    public func addStackedRow(title: String, value: String) -> Self {
        let titleText = Text()
            .setText(to: title)
            .setFont(to: UIFont.systemFont(ofSize: 17, weight: .medium))
            .setTextColor(to: Colors.textMuted)
            .setTextAlignment(to: .left)
        let valueText = Text()
            .setText(to: value)
            .setFont(to: UIFont.systemFont(ofSize: 17, weight: .semibold))
            .setTextAlignment(to: .left)
        let row = VStack()
            .setAlignment(to: .fill)
            .append(titleText)
            .appendGap(size: 1)
            .append(valueText)
        self.stack.append(row)
        return self
    }

    @discardableResult
    public func addDivider() -> Self {
        let divider = View()
            .setHeightConstraint(to: Dimensions.dividerLineWidth)
            .setBackgroundColor(to: Colors.textDark)
            .setOpacity(to: 0.1)
        self.stack.append(divider)
        return self
    }
}
