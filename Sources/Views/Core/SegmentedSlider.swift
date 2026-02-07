//
//  SegmentedSlider.swift
//  https://github.com/Andre-Pham/Zilliax
//
//  Created by Andre Pham.
//

import UIKit

public class SegmentedSlider<T: Any>: View {
    // MARK: Static Computed Properties

    private static var SCRUBBER_DIAMETER: Double {
        return 30.0
    }

    private static var DEFAULT_LABEL_WIDTH: Double {
        return 50.0
    }

    private static var DEFAULT_LABEL_HEIGHT: Double {
        return 35.0
    }

    private static var LABEL_CORNER_RADIUS_HEIGHT_MULTIPLIER: Double {
        return 0.45
    }

    // MARK: Properties

    public let scrubberLabelText = Text()
    public private(set) var segmentIndex = 0
    public private(set) var values = [T]()
    public private(set) var animationDuration: Double? = 0.05
    public private(set) var isTracking = false

    private let container = PanGesture()
    private let scrubberBackground = View()
    private let scrubberLine = View()
    private var scrubberLineSegmentIndicators = [View]()
    private let scrubberControl = View()
    private let scrubberLabel = View()
    private var labels = [String]()
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .light)
    private var onStartTracking: (() -> Void)? = nil
    private var onEndTracking: ((_ value: T) -> Void)? = nil
    private var onChange: ((_ value: T) -> Void)? = nil
    private var progressProportion: CGFloat = 0.0 {
        didSet {
            self.updateCirclePosition()
        }
    }

    // MARK: Computed Properties

    public var activeValue: T {
        return self.values[self.segmentIndex]
    }

    private var activeLabel: String? {
        guard self.labels.count - 1 >= self.segmentIndex else {
            return nil
        }
        return self.labels[self.segmentIndex]
    }

    private var activeValueProgressProportion: CGFloat {
        guard !self.values.isEmpty else {
            return 0.0
        }
        return CGFloat(self.segmentIndex) / CGFloat(self.values.count - 1)
    }

    // MARK: Overridden Functions

    public override func setup() {
        super.setup()

        self.add(self.container)
            .setHeightConstraint(to: Self.SCRUBBER_DIAMETER)

        self.container
            .constrainAllSides(respectSafeArea: false)
            .add(self.scrubberBackground)
            .add(self.scrubberLine)
            .add(self.scrubberControl)
            .setOnGesture({ gesture in
                self.onDrag(gesture)
            })

        self.scrubberBackground
            .setBackgroundColor(to: Colors.fillSecondary)
            .constrainHorizontal(respectSafeArea: false)
            .constrainCenterVertical(respectSafeArea: false)
            .setHeightConstraint(to: Self.SCRUBBER_DIAMETER)
            .setCornerRadius(to: Self.SCRUBBER_DIAMETER / 2.0)

        self.scrubberLine
            .setBackgroundColor(to: .black)
            .setOpacity(to: 0.1)
            .constrainHorizontal(padding: Self.SCRUBBER_DIAMETER / 2.0, respectSafeArea: false)
            .constrainCenterVertical(respectSafeArea: false)
            .setHeightConstraint(to: 5)
            .setCornerRadius(to: 2.5)

        self.scrubberControl
            .setBackgroundColor(to: Colors.accent)
            .setSizeConstraint(to: Self.SCRUBBER_DIAMETER)
            .constrainCenterVertical(respectSafeArea: false)
            .setCornerRadius(to: Self.SCRUBBER_DIAMETER / 2.0)
            .add(self.scrubberLabel)

        self.scrubberLabel
            .constrainCenterHorizontal(respectSafeArea: false)
            .constrainToOnTop(padding: 10.0, respectSafeArea: false)
            .setWidthConstraint(to: Self.DEFAULT_LABEL_WIDTH)
            .setHeightConstraint(to: Self.DEFAULT_LABEL_HEIGHT)
            .setCornerRadius(to: Self.DEFAULT_LABEL_HEIGHT * Self.LABEL_CORNER_RADIUS_HEIGHT_MULTIPLIER)
            .setBackgroundColor(to: Colors.fillForeground)
            .addShadow()
            .add(self.scrubberLabelText)

        self.scrubberLabelText
            .constrainCenterVertical(respectSafeArea: false)
            .constrainCenterHorizontal(respectSafeArea: false)
            .setFont(to: UIFont.systemFont(ofSize: 16, weight: .bold))
            .setTextColor(to: Colors.textDark)

        self.disableScrubberLabel()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        // If any layout occurs the view needs to be re-drawn
        // Otherwise the position is reset
        // Includes: device rotation, size class change (on iPad), light/dark mode changes, moving app to background then foreground, etc.
        // Must occur on the main thread to update (layout callbacks can trigger off the main thread, e.g. size changes on iPad)
        DispatchQueue.main.async {
            self.updateCirclePosition(overrideAnimationDuration: 0.0)
        }
    }

    // MARK: Functions

    @discardableResult
    public func setSegment(index: Int, trigger: Bool = false, useHaptics: Bool = true, isStartingValue: Bool = false) -> Self {
        let animationRestoration = self.animationDuration
        if isStartingValue {
            self.disableAnimation()
        }
        let triggerHaptics = useHaptics && index != self.segmentIndex
        self.segmentIndex = index
        self.setProgress(to: self.activeValueProgressProportion)
        if trigger {
            self.onChange?(self.activeValue)
        }
        if triggerHaptics {
            self.hapticFeedback.impactOccurred()
        }
        if isStartingValue, let animationRestoration {
            self.setAnimationDuration(to: animationRestoration)
            let timelineWidth = self.container.widthConstraintConstant - Self.SCRUBBER_DIAMETER
            let newPosition = self.progressProportion * timelineWidth + Self.SCRUBBER_DIAMETER / 2
            self.scrubberControl.center.x = newPosition
        }
        return self
    }

    @discardableResult
    public func addSegment(value: T, label: String) -> Self {
        self.values.append(value)
        self.labels.append(label)
        self.redrawIndicators()
        return self
    }

    @discardableResult
    public func setOnStartTracking(_ callback: (() -> Void)?) -> Self {
        self.onStartTracking = callback
        return self
    }

    @discardableResult
    public func setOnEndTracking(_ callback: ((_ value: T) -> Void)?) -> Self {
        self.onEndTracking = callback
        return self
    }

    @discardableResult
    public func setOnChange(_ callback: ((_ value: T) -> Void)?) -> Self {
        self.onChange = callback
        return self
    }

    @discardableResult
    public func disableAnimation() -> Self {
        self.animationDuration = nil
        return self
    }

    @discardableResult
    public func setAnimationDuration(to duration: Double) -> Self {
        self.animationDuration = duration
        return self
    }

    private func redrawScrubberLabel() {
        guard let labelText = self.activeLabel else {
            assertionFailure("Failed to retrieve label - something has gone very wrong")
            return
        }
        self.scrubberLabelText.setText(to: labelText)
        self.scrubberLabel
            .removeWidthConstraint()
            .removeHeightConstraint()
        let textSize = self.scrubberLabelText.contentBasedSize
        let horizontalPadding = 12.0
        let verticalPadding = 10.0
        let fittedWidth = textSize.width + horizontalPadding * 2
        let fittedHeight = textSize.height + verticalPadding * 2
        if fittedWidth.isGreater(than: Self.DEFAULT_LABEL_WIDTH) {
            self.scrubberLabel.setWidthConstraint(to: fittedWidth)
        } else {
            self.scrubberLabel.setWidthConstraint(to: Self.DEFAULT_LABEL_WIDTH)
        }
        if fittedHeight.isGreater(than: Self.DEFAULT_LABEL_HEIGHT) {
            self.scrubberLabel
                .setHeightConstraint(to: fittedHeight)
                .setCornerRadius(to: fittedHeight * Self.LABEL_CORNER_RADIUS_HEIGHT_MULTIPLIER)
        } else {
            self.scrubberLabel
                .setHeightConstraint(to: Self.DEFAULT_LABEL_HEIGHT)
                .setCornerRadius(to: Self.DEFAULT_LABEL_HEIGHT * Self.LABEL_CORNER_RADIUS_HEIGHT_MULTIPLIER)
        }
        self.scrubberLabel.reframeIntoWindow(
            padding: Dimensions.screenContentPaddingHorizontal / 2.0,
            inset: Dimensions.screenContentPaddingHorizontal / 2.0
        )
    }

    private func activateScrubberLabel() {
        self.scrubberLabel.setHidden(to: false)
    }

    private func disableScrubberLabel() {
        self.scrubberLabel.setHidden(to: true)
    }

    private func redrawIndicators() {
        for scrubberLineSegmentIndicator in self.scrubberLineSegmentIndicators {
            scrubberLineSegmentIndicator.remove()
        }
        self.scrubberLineSegmentIndicators.removeAll()
        for indicatorIndex in self.values.indices {
            let indicator = View()
            self.scrubberLineSegmentIndicators.append(indicator)
            self.scrubberLine.add(indicator)
            let height = Self.SCRUBBER_DIAMETER * 0.4
            let width = Self.SCRUBBER_DIAMETER * 0.4
            let cornerRadius = width / 2.0
            indicator
                .constrainCenterVertical(respectSafeArea: false)
                .constrainHorizontalByProportion(
                    proportionFromLeft: Double(indicatorIndex) / Double(self.values.count == 1 ? 1 : self.values.count - 1)
                )
                .setBackgroundColor(to: .black)
                .setHeightConstraint(to: height)
                .setWidthConstraint(to: width)
                .setCornerRadius(to: cornerRadius)
        }
    }

    private func setProgress(to proportion: Double) {
        self.progressProportion = min(1.0, max(0.0, proportion))
    }

    private func onDrag(_ gesture: UIPanGestureRecognizer) {
        guard !self.values.isEmpty else {
            return
        }
        switch gesture.state {
        case .began:
            self.isTracking = true
            self.redrawScrubberLabel()
            self.activateScrubberLabel()
            self.onStartTracking?()
        case .changed:
            // Calculate the drag position (disregarding segments)
            let containerWidth = self.container.frame.width
            let lineWidth = containerWidth - Self.SCRUBBER_DIAMETER
            let positionInContainer = gesture.location(in: self.container).x
            let positionInLine = {
                let clampedPosition = min(
                    containerWidth - Self.SCRUBBER_DIAMETER / 2.0,
                    max(Self.SCRUBBER_DIAMETER / 2.0, positionInContainer)
                )
                return clampedPosition - Self.SCRUBBER_DIAMETER / 2.0
            }()
            let newProgress = min(1.0, max(0.0, positionInLine / lineWidth))
            // Calculate the segment that corresponds to that position
            var candidateState = 0
            var finalState = 0
            var finalDistance: Double? = nil
            while candidateState < self.values.endIndex {
                let candidateStateTargetProportion = Double(candidateState) / Double(self.values.count - 1)
                let candidateDifference = abs(newProgress - candidateStateTargetProportion)
                if finalDistance == nil || candidateDifference.isLess(than: finalDistance!) {
                    finalDistance = candidateDifference
                    finalState = candidateState
                } else {
                    break
                }
                candidateState += 1
            }
            self.setSegment(index: finalState, trigger: true)
            // Show label of segment
            self.redrawScrubberLabel()
        case .ended, .cancelled, .failed:
            self.isTracking = false
            self.disableScrubberLabel()
            self.onEndTracking?(self.activeValue)
        default:
            break
        }
    }

    private func updateCirclePosition(overrideAnimationDuration: Double? = nil) {
        let timelineWidth = self.container.bounds.width - Self.SCRUBBER_DIAMETER
        let newPosition = self.progressProportion * timelineWidth + Self.SCRUBBER_DIAMETER / 2
        let animationDuration = overrideAnimationDuration ?? self.animationDuration
        if let animationDuration, animationDuration.isGreaterThanZero() {
            UIView.animate(withDuration: animationDuration, delay: 0, options: [.curveLinear, .allowUserInteraction], animations: {
                self.scrubberControl.center.x = newPosition
            })
        } else {
            self.scrubberControl.center.x = newPosition
        }
    }
}
