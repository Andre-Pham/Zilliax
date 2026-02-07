//
//  SegmentedControl.swift
//  https://github.com/Andre-Pham/Zilliax
//
//  Created by Andre Pham.
//

import UIKit

public class SegmentedControl<T: Any>: View {
    // MARK: Nested Types

    public enum Distribution {
        case fillEqually
        case fillProportionally

        fileprivate var stackDistribution: UIStackView.Distribution {
            switch self {
            case .fillEqually:
                return .fillEqually
            case .fillProportionally:
                return .fillProportionally
            }
        }
    }

    // MARK: Static Computed Properties

    private static var HEIGHT: Double {
        return 50.0
    }

    private static var INNER_PADDING: Double {
        return 5.0
    }

    // MARK: Properties

    private let selection = View()
    private let segmentStack = HStack()
    private let panGesture = PanGesture()
    private var segments = [View]()
    private var values = [T]()
    private var selectedIndex: Int? = nil
    private var onChange: ((_ value: T) -> Void)? = nil
    private var selectedConstraints: (
        vertical: NSLayoutConstraint,
        horizontal: NSLayoutConstraint,
        width: NSLayoutConstraint
    )? = nil

    // MARK: Computed Properties

    private var selectedSegment: View? {
        guard let selectedIndex else {
            return nil
        }
        guard selectedIndex < self.segments.count else {
            return nil
        }
        return self.segments[selectedIndex]
    }

    private var selectedValue: T? {
        guard let selectedIndex else {
            return nil
        }
        guard selectedIndex < self.segments.count else {
            return nil
        }
        return self.values[selectedIndex]
    }

    // MARK: Overridden Functions

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

        self.panGesture
            .addGestureRecognizer(to: self)
            .setOnGesture({ gesture in
                self.handlePan(gesture)
            })
            .setCancelsTouchesInView(to: false)
    }

    // MARK: Functions

    @discardableResult
    public func setOnChange(_ callback: ((_ value: T) -> Void)?) -> Self {
        self.onChange = callback
        return self
    }

    @discardableResult
    public func setDistribution(to distribution: Distribution) -> Self {
        self.segmentStack.setDistribution(to: distribution.stackDistribution)
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
                self.setSelectedSegment(index: segmentIndex, animated: true)
                self.selection.setTransformation(to: CGAffineTransform(scaleX: 0.95, y: 0.95), animated: true)
            })
            .setOnRelease({
                self.selection.setTransformation(to: .identity, animated: true)
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
        self.values.append(value)

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
            if let selectedValue {
                self.onChange?(selectedValue)
            } else {
                assertionFailure("Expected selected value to be defined")
            }
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

    private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard !self.segments.isEmpty else {
            return
        }
        let location = gesture.location(in: self.segmentStack)
        let index = self.segmentIndex(for: location)
        if gesture.state == .began {
            self.selection.setTransformation(to: CGAffineTransform(scaleX: 0.95, y: 0.95), animated: true)
        }
        if gesture.state == .ended || gesture.state == .cancelled || gesture.state == .failed {
            self.selection.setTransformation(to: .identity, animated: true)
        }
        if gesture.state == .changed {
            self.setSelectedSegment(index: index, animated: true)
        }
        if gesture.state == .ended {
            self.setSelectedSegment(index: index, animated: true)
        }
    }

    private func segmentIndex(for location: CGPoint) -> Int {
        let segmentCount = self.segments.count
        let width = self.segmentStack.bounds.width
        guard segmentCount > 0, width > 0 else {
            return 0
        }
        let segmentWidth = width / CGFloat(segmentCount)
        let index = Int(location.x / segmentWidth)
        return min(max(index, 0), segmentCount - 1)
    }
}
