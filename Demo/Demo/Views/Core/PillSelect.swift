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
    private var pills = [PillToggle]()
    private var values = [T]()
    private var selectedIndex: Int? = nil
    private var onChange: ((_ value: T?) -> Void)? = nil
    private var requireSelection = false

    // MARK: Computed Properties

    private var selectedPill: PillToggle? {
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
    public func setOnChange(_ callback: ((_ value: T?) -> Void)?) -> Self {
        self.onChange = callback
        return self
    }

    @discardableResult
    public func addSegment(value: T, label: String, icon: IconImage.Config? = nil) -> Self {
        let pill = PillToggle()
            .setLabel(to: label)

        if let icon {
            pill.setIcon(to: icon)
        }

        let segmentIndex = self.pills.count

        pill.setOnToggle({ [weak self] isOn in
            guard let self = self else {
                return
            }
            if isOn {
                self.setSelectedSegment(index: segmentIndex, trigger: true)
            } else {
                self.setSelectedSegment(index: nil, trigger: true)
            }
        })

        self.flowLayout.append(pill)
        self.pills.append(pill)
        self.values.append(value)

        if self.requireSelection, self.selectedIndex == nil {
            self.setSelectedSegment(index: 0)
        } else {
            self.updateSelection()
        }

        return self
    }

    @discardableResult
    public func setSelectedSegment(index: Int?, trigger: Bool = false) -> Self {
        guard self.selectedIndex != index else {
            return self
        }
        if let index, index < 0 || index >= self.pills.count {
            assertionFailure("Invalid index provided: \(index)")
            return self
        }
        self.selectedIndex = index
        self.updateSelection()
        if trigger {
            self.onChange?(self.selectedValue)
        }
        return self
    }
    
    @discardableResult
    public func setRequiredSelection(to state: Bool) -> Self {
        self.requireSelection = state
        if self.requireSelection, self.selectedIndex == nil, !self.pills.isEmpty {
            self.setSelectedSegment(index: 0)
        } else {
            self.updateSelection()
        }
        return self
    }

    private func updateSelection() {
        for (index, pill) in self.pills.enumerated() {
            let isSelected = index == self.selectedIndex
            pill.setState(isOn: isSelected)
            if self.requireSelection {
                pill.setLocked(to: isSelected)
            }
        }
    }
}

// TODO: Define a callback for `Button` passed in to `animateOnPress` with params `onPress` and `onRelease`
// TODO: Then use it here, just re-copy PillButton again, but change the height, and pass in `onPress` and `onRelease`
// TODO: Name it `PillToggle`
// TODO: Then define functions on it like `setToggled(to state: Bool)` and `setToggledColors(background:, foreground:)`
// TODO: Define it in its own file
// TODO: Then use it in components like this, and obviously add it to the ViewsViewController

private class PillToggle: View {
    // MARK: Static Properties

    private static let HEIGHT = 36.0

    // MARK: Properties

    public private(set) var isOn = false

    private let contentStack = HStack()
    private let button = Button()
    private let icon = IconImage()
    private let label = Text()
    private var onToggle: ((_ isOn: Bool) -> Void)? = nil
    private var iconAdded = false
    private var labelAdded = false
    private var isLocked = false
    private var onColors: (background: UIColor, foreground: UIColor) = (Colors.fillPrimary, Colors.textPrimary)
    private var offColors: (background: UIColor, foreground: UIColor) = (Colors.fillSecondary, Colors.textSecondary)

    // MARK: Computed Properties

    public var isOff: Bool {
        return !self.isOn
    }

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
            .setOnRelease({ [weak self] in
                self?.toggle()
            })
            .animateOnPress(
                self,
                onPress: { view in
                    view.setTransformation(to: CGAffineTransform(scaleX: 0.95, y: 0.95), animated: true)
                },
                onRelease: { view in
                    view.setTransformation(to: .identity, animated: true)
                }
            )

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
    public func setColors(
        on: (background: UIColor, foreground: UIColor),
        off: (background: UIColor, foreground: UIColor)
    ) -> Self {
        self.onColors = on
        self.offColors = off
        self.updateColors()
        return self
    }

    @discardableResult
    public func setState(isOn: Bool, trigger: Bool = false) -> Self {
        guard self.isOn != isOn else {
            return self
        }
        self.isOn = isOn
        self.updateColors()
        if trigger {
            self.onToggle?(self.isOn)
        }
        return self
    }

    @discardableResult
    public func setOnToggle(_ callback: ((_ isOn: Bool) -> Void)?) -> Self {
        self.onToggle = callback
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
    public func setLocked(to state: Bool) -> Self {
        self.isLocked = state
        return self
    }

    private func toggle() {
        guard !self.isLocked else {
            return
        }
        self.isOn.toggle()
        self.updateColors()
        self.onToggle?(self.isOn)
    }

    private func updateColors() {
        let backgroundColor = self.isOn ? self.onColors.background : self.offColors.background
        let foregroundColor = self.isOn ? self.onColors.foreground : self.offColors.foreground
        self.setBackgroundColor(to: backgroundColor)
        self.icon.setColor(to: foregroundColor)
        self.label.setTextColor(to: foregroundColor)
    }
}
