//
//  PillSelect.swift
//  https://github.com/Andre-Pham/Zilliax
//
//  Created by Andre Pham.
//

import UIKit

public class PillSelect<T: Any>: View {
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
            .setSpacing(to: 8)
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
    public func setSelectedSegment(value: T?, trigger: Bool = false) -> Self where T: Equatable {
        guard let value else {
            return self.setSelectedSegment(index: nil, trigger: trigger)
        }
        guard let index = self.values.firstIndex(where: { $0 == value }) else {
            assertionFailure("Attempted to select segment for non existent value: \(value)")
            return self
        }
        return self.setSelectedSegment(index: index, trigger: trigger)
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

    @discardableResult
    public func setHorizontalAlignment(to alignment: FlowLayout.HorizontalAlignment) -> Self {
        self.flowLayout.setHorizontalAlignment(to: alignment)
        return self
    }

    @discardableResult
    public func setVerticalAlignment(to alignment: FlowLayout.VerticalAlignment) -> Self {
        self.flowLayout.setVerticalAlignment(to: alignment)
        return self
    }

    @discardableResult
    public func setDirection(to direction: FlowLayout.Direction) -> Self {
        self.flowLayout.setDirection(to: direction)
        return self
    }

    private func updateSelection() {
        for (index, pill) in self.pills.enumerated() {
            let isSelected = index == self.selectedIndex
            pill.setState(isOn: isSelected)
            if self.requireSelection {
                pill.setLocked(to: isSelected)
            } else {
                pill.setLocked(to: false)
            }
        }
    }
}
