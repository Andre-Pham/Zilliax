//
//  PillSelect.swift
//  https://github.com/Andre-Pham/Zilliax
//
//  Created by Andre Pham.
//

import UIKit

public class PillSelect<T: Any>: View {
    // MARK: Static Computed Properties

    private static var SPACING: Double { 8.0 }

    // MARK: Properties

    private let flowLayout = FlowLayout()
    private var pills = [Pill]()
    private var values = [T]()
    private var selectedIndex: Int? = nil
    private var onChange: ((_ value: T) -> Void)? = nil

    // MARK: Computed Properties

    private var selectedPill: Pill? {
        guard let selectedIndex else {
            return nil
        }
        guard selectedIndex < self.pills.count else {
            return nil
        }
        return self.pills[selectedIndex]
    }

    private var selectedValue: T? {
        guard let selectedIndex else {
            return nil
        }
        guard selectedIndex < self.values.count else {
            return nil
        }
        return self.values[selectedIndex]
    }

    // MARK: Overridden Functions

    public override func setup() {
        super.setup()

        self.add(self.flowLayout)

        self.flowLayout
            .constrainAllSides(respectSafeArea: false)
            .setSpacing(to: Self.SPACING)
    }

    // MARK: Functions

    @discardableResult
    public func setOnChange(_ callback: ((_ value: T) -> Void)?) -> Self {
        self.onChange = callback
        return self
    }

    @discardableResult
    public func addSegment(value: T, label: String, icon: IconImage.Config? = nil) -> Self {
        let pill = Pill()
            .setLabel(to: label)
            .setColor(to: Colors.fillSecondary)
            .setForegroundColor(to: Colors.textSecondary)

        if let icon {
            pill.setIcon(to: icon)
        }

        let segmentIndex = self.pills.count

        pill.setOnTap({
            self.setSelectedSegment(index: segmentIndex, animated: true)
        })

        self.flowLayout.append(pill)
        self.pills.append(pill)
        self.values.append(value)

        if self.selectedIndex == nil {
            self.selectedIndex = 0
        }

        self.redrawSelection(animated: false)

        return self
    }

    @discardableResult
    public func setSelectedSegment(index: Int, animated: Bool) -> Self {
        guard index >= 0, index < self.pills.count else {
            assertionFailure("Invalid index provided: \(index)")
            return self
        }
        guard self.selectedIndex != index else {
            return self
        }
        self.selectedIndex = index
        self.redrawSelection(animated: animated)
        return self
    }

    @discardableResult
    private func redrawSelection(animated: Bool) -> Self {
        let updateColors = {
            for (index, pill) in self.pills.enumerated() {
                let isSelected = index == self.selectedIndex
                let backgroundColor = isSelected ? Colors.fillPrimary : Colors.fillSecondary
                let foregroundColor = isSelected ? Colors.textPrimary : Colors.textSecondary
                pill.setColor(to: backgroundColor)
                    .setForegroundColor(to: foregroundColor)
            }
        }

        updateColors()

        if let selectedValue, self.selectedPill != nil {
            self.onChange?(selectedValue)
        } else if self.selectedIndex != nil {
            assertionFailure("Expected selected value to be defined")
        }

        return self
    }
}

// TODO: Define a callback for `Button` passed in to `animateOnPress` with params `onPress` and `onRelease`
// TODO: Then use it here, just re-copy PillButton again, but change the height, and pass in `onPress` and `onRelease`
// TODO: Name it `PillToggle`
// TODO: Then define functions on it like `setToggled(to state: Bool)` and `setToggledColors(background:, foreground:)`
// TODO: Define it in its own file
// TODO: Then use it in components like this, and obviously add it to the ViewsViewController

private class Pill: View {
    // MARK: Static Properties

    private static let HEIGHT = 36.0

    // MARK: Properties

    private let contentStack = HStack()
    private let button = Button()
    private let icon = IconImage()
    private let label = Text()
    private var onTap: (() -> Void)? = nil
    private var iconAdded = false
    private var labelAdded = false

    // MARK: Computed Properties

    public var isDisabled: Bool {
        return self.button.isDisabled
    }

    // MARK: Overridden Functions

    public override func setup() {
        super.setup()

        self.setHeightConstraint(to: Self.HEIGHT)
            .setBackgroundColor(to: Colors.fillSecondary)
            .setCornerRadius(to: Self.HEIGHT / 2)
            .add(self.contentStack)
            .add(self.button)

        self.contentStack
            .constrainVertical(respectSafeArea: false)
            .constrainCenterHorizontal(respectSafeArea: false)
            .setSpacing(to: 8)
            .constrainMaxLeft(padding: 18)
            .constrainMaxRight(padding: 18)

        self.button
            .constrainAllSides(respectSafeArea: false)
            .setOnPress({
                self.setTransformation(to: CGAffineTransform(scaleX: 0.95, y: 0.95), animated: true)
            })
            .setOnRelease({
                self.setTransformation(to: .identity, animated: true)
                self.onTap?()
            })

        self.icon
            .setColor(to: Colors.textSecondary)

        self.label
            .setFont(to: UIFont.systemFont(ofSize: 15, weight: .semibold))
            .setTextAlignment(to: .center)
    }

    // MARK: Functions

    @discardableResult
    public func setIcon(to config: IconImage.Config) -> Self {
        if !self.iconAdded {
            if self.labelAdded {
                self.contentStack.insert(self.icon, at: self.contentStack.viewCount - 1)
            } else {
                self.contentStack.append(self.icon)
            }
            self.iconAdded = true
        }
        self.icon.setIcon(to: config)
        return self
    }

    @discardableResult
    public func setLabel(to label: String) -> Self {
        if !self.labelAdded {
            self.contentStack.append(self.label)
            self.labelAdded = true
        }
        self.label.setText(to: label)
        return self
    }

    @discardableResult
    public func setLabelSize(to size: CGFloat) -> Self {
        self.label.setSize(to: size)
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

    @discardableResult
    public func setOnTap(_ callback: (() -> Void)?) -> Self {
        self.onTap = callback
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
}
