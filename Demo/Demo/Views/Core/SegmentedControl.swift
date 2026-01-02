//
//  SegmentedControl.swift
//  https://github.com/Andre-Pham/Zilliax
//
//  Created by Andre Pham.
//

import UIKit

public class SegmentedControl<T: Any>: View {
    private static var HEIGHT: Double { 50.0 }
    private static var INNER_PADDING: Double { 5.0 }
    
    private let selection = View()
    private let segmentStack = HStack()
    private var segments = [View]()
    private var selectedIndex: Int? = nil
    private var selectedSegment: View? {
        guard let selectedIndex else {
            return nil
        }
        guard selectedIndex < self.segments.count else {
            return nil
        }
        return self.segments[selectedIndex]
    }
    private var selectedConstraints: (
        vertical: NSLayoutConstraint,
        horizontal: NSLayoutConstraint,
        width: NSLayoutConstraint
    )? = nil
    
    public override func setup() {
        super.setup()
        
        self.setHeightConstraint(to: Self.HEIGHT)
            .setBackgroundColor(to: Colors.fillSecondary)
            .setCornerRadius(to: Self.HEIGHT / 2)
            .add(self.selection)
            .add(self.segmentStack)
        
        self.selection
            .setHeightConstraint(to: Self.HEIGHT - Self.INNER_PADDING * 2)
            .setBackgroundColor(to: Colors.fillForeground)
            .setCornerRadius(to: (Self.HEIGHT - Self.INNER_PADDING * 2) / 2)

        self.segmentStack
            .constrainAllSides(respectSafeArea: false)
            .setDistribution(to: .fillEqually)
    }
    
    @discardableResult
    public func setDistribution(to distribution: UIStackView.Distribution) -> Self {
        // TODO: Can this only accept .fillEqually | .fillProportionally
        self.segmentStack.setDistribution(to: distribution)
        return self
    }
    
    @discardableResult
    public func addSegment(value: T, label: String, icon: IconImage.Config? = nil) -> Self {
        let segment = View()
            .setHeightConstraint(to: Self.HEIGHT)
        
        let segmentText = Text()
            .setFont(to: UIFont.systemFont(ofSize: 18, weight: .medium))
            .setText(to: label)
        
        let segmentStack = HStack()
            .addAsSubview(of: segment)
            .constrainCenterHorizontal()
            .constrainVertical()
            .constrainMaxHorizontal()
            .setSpacing(to: 8)
            .setAlignment(to: .center)
            .appendGap(size: 12)
            .append(segmentText)
            .appendGap(size: 12)
        
        let segmentIndex = self.segments.count
        
        Control()
            .addAsSubview(of: segment)
            .constrainAllSides()
            .setOnPress({
                // TODO: When you hold down, the selection view should shrink (scale down) (animated)
                // TODO: When you let go, the scale transformation should reset (animated)
                // TODO: I should also be able to drag around the selected segment to change my selection
                // TODO: All the other stuff, like callbacks whenever the value changes
                self.setSelectedSegment(index: segmentIndex, animated: true)
            })
        
        if let icon {
            let segmentIcon = IconImage()
                .setSize(to: 14)
                .setWeight(to: .bold)
                .setIcon(to: icon)
            segmentStack.insert(segmentIcon, at: 2)
        }
        
        self.segmentStack.append(segment)
        self.segments.append(segment)
        
        if self.selectedIndex == nil {
            self.selectedIndex = 0
        }
        
        self.redrawSelection()

        return self
    }
    
    @discardableResult
    public func setSelectedSegment(index: Int, animated: Bool) -> Self {
        guard index >= 0, index < self.segments.count else {
            assertionFailure("Invalid index provided: \(index)")
            return self
        }
        guard self.selectedIndex != index else {
            return self
        }
        self.selectedIndex = index
        self.redrawSelection()
        if animated {
            UIView.animate(
                withDuration: 0.2,
                delay: 0,
                usingSpringWithDamping: 1.0,
                initialSpringVelocity: 2,
                options: [.curveEaseInOut, .allowUserInteraction, .beginFromCurrentState],
                animations: {
                    self.layoutIfNeeded()
                },
                completion: nil
            )
        } else {
            self.layoutIfNeeded()
        }
        return self
    }
    
    @discardableResult
    private func redrawSelection() -> Self {
        if let selectedSegment {
            if let selectedConstraints {
                selectedConstraints.vertical.isActive = false
                selectedConstraints.horizontal.isActive = false
                selectedConstraints.width.isActive = false
            }
            let vertical = self.selection.constrainCenterVerticalValue()
            let horizontal = self.selection.constrainCenterHorizontalValue(to: selectedSegment)
            let width = self.selection.matchWidthConstraintValue(to: selectedSegment, adjust: Self.INNER_PADDING * -2)
            self.selectedConstraints = (vertical: vertical, horizontal: horizontal, width: width)
        } else {
            if let selectedConstraints {
                selectedConstraints.vertical.isActive = false
                selectedConstraints.horizontal.isActive = false
                selectedConstraints.width.isActive = false
                self.selectedConstraints = nil
            }
        }
        return self
    }
}
