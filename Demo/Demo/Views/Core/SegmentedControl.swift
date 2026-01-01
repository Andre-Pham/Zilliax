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
            .constrainMaxLeft(padding: 24)
            .constrainMaxRight(padding: 24)
            .setDistribution(to: .fillEqually)
        
//        let s1v = View()
//            .addBorder(color: .blue)
//        let s1 = HStack()
//            .addAsSubview(of: s1v)
//            .constrainCenterHorizontal()
//            .constrainVertical()
//            .constrainMaxHorizontal()
//            .setSpacing(to: 8)
//            .setAlignment(to: .center)
//            .addBorder()
//        s1
//            .appendGap(size: 12)
//            .append(Text().setText(to: "Hello World"))
//            .append(IconImage().setIcon(to: .init(systemName: "arrow.up", size: 14, weight: .bold)))
//            .appendGap(size: 12)
//        self.segmentStack.append(s1v)
//        
//        let s2v = View()
//            .addBorder(color: .blue)
//        let s2 = HStack()
//            .addAsSubview(of: s2v)
//            .constrainCenterHorizontal()
//            .constrainVertical()
//            .constrainMaxHorizontal()
//            .setSpacing(to: 8)
//            .setAlignment(to: .center)
//            .addBorder()
//        s2
//            .appendGap(size: 12)
//            .append(Text().setText(to: "Bye"))
//            .appendGap(size: 12)
//        self.segmentStack.append(s2v)
//        
//        self.selection
//            .constrainCenterVertical()
//            .constrainCenterHorizontal(to: s1v)
//            .matchWidthConstraint(to: s1v, adjust: Self.INNER_PADDING * -2)
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
