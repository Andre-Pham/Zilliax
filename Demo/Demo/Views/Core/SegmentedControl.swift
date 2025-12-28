//
//  SegmentedControl.swift
//  https://github.com/Andre-Pham/Zilliax
//
//  Created by Andre Pham.
//

import UIKit

public class SegmentedControl: View {
    private static let HEIGHT = 50.0
    private static let INNER_PADDING = 5.0
    
    private let selection = View()
    private let segmentStack = HStack()
    
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
        
        let s1v = View()
            .addBorder(color: .blue)
        let s1 = HStack()
            .addAsSubview(of: s1v)
            .constrainCenterHorizontal()
            .constrainVertical()
            .constrainMaxHorizontal()
            .setSpacing(to: 8)
            .setAlignment(to: .center)
            .addBorder()
        s1
            .appendGap(size: 12)
            .append(Text().setText(to: "Hello World"))
            .append(IconImage().setIcon(to: .init(systemName: "arrow.up", size: 14, weight: .bold)))
            .appendGap(size: 12)
        self.segmentStack.append(s1v)
        
        let s2v = View()
            .addBorder(color: .blue)
        let s2 = HStack()
            .addAsSubview(of: s2v)
            .constrainCenterHorizontal()
            .constrainVertical()
            .constrainMaxHorizontal()
            .setSpacing(to: 8)
            .setAlignment(to: .center)
            .addBorder()
        s2
            .appendGap(size: 12)
            .append(Text().setText(to: "Bye"))
            .appendGap(size: 12)
        self.segmentStack.append(s2v)
        
        self.selection
            .constrainCenterVertical()
            .constrainCenterHorizontal(to: s1v)
            .matchWidthConstraint(to: s1v, adjust: Self.INNER_PADDING * -2)
    }
    
    @discardableResult
    public func setDistribution(to distribution: UIStackView.Distribution) -> Self {
        // TODO: Can this only accept .fillEqually | .fillProportionally
        self.segmentStack.setDistribution(to: distribution)
        return self
    }
}
