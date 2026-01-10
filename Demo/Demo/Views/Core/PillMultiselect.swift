//
//  PillMultiselect.swift
//  https://github.com/Andre-Pham/Zilliax
//
//  Created by Andre Pham.
//

import UIKit

public class PillMultiselect<T: Any>: View {
    // MARK: Properties

    private let flowLayout = FlowLayout()
    private var pills = [PillToggle]()
    private var values = [T]()
    private var selectedIndices = Set<Int>()
    private var onChange: ((_ values: [T]) -> Void)? = nil
    private var requireSelection = false

    // MARK: Computed Properties

    private var selectedPills: [PillToggle] {
        return self.sortedSelectedIndices().compactMap { index in
            guard index < self.pills.count else {
                return nil
            }
            return self.pills[index]
        }
    }

    private var selectedValues: [T] {
        return self.sortedSelectedIndices().compactMap { index in
            guard index < self.values.count else {
                return nil
            }
            return self.values[index]
        }
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
    public func setOnChange(_ callback: ((_ values: [T]) -> Void)?) -> Self {
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
                self.insertSelectedIndex(segmentIndex, trigger: true)
            } else {
                self.removeSelectedIndex(segmentIndex, trigger: true)
            }
        })

        self.flowLayout.append(pill)
        self.pills.append(pill)
        self.values.append(value)

        if self.requireSelection, self.selectedIndices.isEmpty {
            self.setSelectedSegments(indices: [0])
        } else {
            self.updateSelection()
        }

        return self
    }

    @discardableResult
    public func setSelectedSegment(index: Int?, trigger: Bool = false) -> Self {
        if let index {
            return self.setSelectedSegments(indices: [index], trigger: trigger)
        }
        return self.setSelectedSegments(indices: [], trigger: trigger)
    }

    @discardableResult
    public func setSelectedSegments(indices: Set<Int>, trigger: Bool = false) -> Self {
        if let invalidIndices = self.invalidIndices(from: indices) {
            assertionFailure("Invalid indices provided: \(invalidIndices)")
            return self
        }

        var nextIndices = indices
        if self.requireSelection, nextIndices.isEmpty, !self.pills.isEmpty {
            nextIndices = [0]
        }

        guard self.selectedIndices != nextIndices else {
            return self
        }

        self.selectedIndices = nextIndices
        self.updateSelection()
        if trigger {
            self.onChange?(self.selectedValues)
        }
        return self
    }

    @discardableResult
    public func setRequiredSelection(to state: Bool) -> Self {
        self.requireSelection = state
        if self.requireSelection, self.selectedIndices.isEmpty, !self.pills.isEmpty {
            self.setSelectedSegments(indices: [0])
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

    private func insertSelectedIndex(_ index: Int, trigger: Bool) {
        guard index >= 0, index < self.pills.count else {
            assertionFailure("Invalid index provided: \(index)")
            return
        }
        guard !self.selectedIndices.contains(index) else {
            return
        }
        self.selectedIndices.insert(index)
        self.updateSelection()
        if trigger {
            self.onChange?(self.selectedValues)
        }
    }

    private func removeSelectedIndex(_ index: Int, trigger: Bool) {
        guard self.selectedIndices.contains(index) else {
            return
        }
        if self.requireSelection, self.selectedIndices.count == 1 {
            self.updateSelection()
            return
        }
        self.selectedIndices.remove(index)
        self.updateSelection()
        if trigger {
            self.onChange?(self.selectedValues)
        }
    }

    private func updateSelection() {
        let singleSelectionLock = self.requireSelection && self.selectedIndices.count == 1
        for (index, pill) in self.pills.enumerated() {
            let isSelected = self.selectedIndices.contains(index)
            pill.setState(isOn: isSelected)
            pill.setLocked(to: singleSelectionLock && isSelected)
        }
    }

    private func sortedSelectedIndices() -> [Int] {
        return self.selectedIndices.sorted()
    }

    private func invalidIndices(from indices: Set<Int>) -> [Int]? {
        let invalid = indices.filter { $0 < 0 || $0 >= self.pills.count }.sorted()
        return invalid.isEmpty ? nil : invalid
    }
}
