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
            .setSpacing(to: 8)
            .setAlignment(to: .fill)
    }

    // MARK: Functions

    @discardableResult
    public func addTitleRow(title: String) -> Self {
        let titleText = Text()
            .setText(to: title)
            .setFont(to: UIFont.systemFont(ofSize: 16, weight: .semibold))
        self.stack.append(titleText)
        return self
    }

    @discardableResult
    public func addRow(title: String, value: String) -> Self {
        let titleText = Text()
            .setText(to: title)
            .setFont(to: UIFont.systemFont(ofSize: 16, weight: .medium))
            .setTextColor(to: Colors.textMuted)
        let valueText = Text()
            .setText(to: value)
            .setFont(to: UIFont.systemFont(ofSize: 16, weight: .semibold))
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
            .setFont(to: UIFont.systemFont(ofSize: 16, weight: .medium))
            .setTextColor(to: Colors.textMuted)
            .setTextAlignment(to: .left)
        let valueText = Text()
            .setText(to: value)
            .setFont(to: UIFont.systemFont(ofSize: 16, weight: .semibold))
            .setTextAlignment(to: .left)
        let row = VStack()
            .setAlignment(to: .fill)
            .append(titleText)
            .appendGap(size: 4)
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
        if let previousView = self.stack.arrangedSubviews.last {
            self.stack.setCustomSpacing(after: previousView, to: 12)
        }
        self.stack.append(divider)
        self.stack.setCustomSpacing(after: divider, to: 12)
        return self
    }
}
