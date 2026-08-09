//
//  Slider.swift
//  https://github.com/Andre-Pham/Zilliax
//
//  Created by Andre Pham.
//

import UIKit

public class Slider: View {
    // MARK: Static Properties

    private static let SCRUBBER_DIAMETER = 30.0
    private static let DEFAULT_LABEL_WIDTH = 50.0
    private static let DEFAULT_LABEL_HEIGHT = 35.0
    private static let LABEL_CORNER_RADIUS_HEIGHT_MULTIPLIER = 0.45

    // MARK: Properties

    public let scrubberLabelText = Text()

    public private(set) var progressProportion: CGFloat = 0.0 {
        didSet {
            self.updateCirclePosition()
        }
    }

    public private(set) var isTracking = false
    public private(set) var isDisabled = false
    public private(set) var minValue = 0.0
    public private(set) var maxValue = 1.0

    private let container = PanGesture()
    private let scrubberBackground = View()
    private let scrubberLine = View()
    private let scrubberControl = View()
    private let scrubberLabel = View()
    private var label: ((_ proportion: Double, _ value: Double) -> String)? = nil
    private var onStartTracking: (() -> Void)? = nil
    private var onEndTracking: (() -> Void)? = nil
    private var onChange: ((_ proportion: Double, _ value: Double) -> Void)? = nil

    // MARK: Computed Properties

    /// The current selected value derived from the proportion, min value, and max value
    public var value: Double {
        guard let valueRange = self.valueRange else {
            return self.minValue
        }
        return self.minValue + self.progressProportion * valueRange
    }

    /// The distance between the min and max values, or nil if the range is invalid
    private var valueRange: Double? {
        if self.maxValue.isLess(than: self.minValue) {
            assertionFailure("Max value must be greater or equal to min value")
            return nil
        }
        return self.maxValue - self.minValue
    }

    // MARK: Overridden Functions

    public override func setup() {
        super.setup()

        self.add(self.container)
            .setHeightConstraint(to: Self.SCRUBBER_DIAMETER)

        self.container
            .constrainAllSides()
            .add(self.scrubberBackground)
            .add(self.scrubberLine)
            .add(self.scrubberControl)
            .setOnGesture({ [weak self] gesture in
                self?.onDrag(gesture)
            })

        self.scrubberBackground
            .setBackgroundColor(to: Colors.fillSecondary)
            .constrainHorizontal()
            .constrainCenterVertical()
            .setHeightConstraint(to: Self.SCRUBBER_DIAMETER)
            .setCornerRadius(to: Self.SCRUBBER_DIAMETER / 2.0)

        self.scrubberLine
            .setBackgroundColor(to: .black)
            .setOpacity(to: 0.1)
            .constrainHorizontal(padding: Self.SCRUBBER_DIAMETER / 2.0)
            .constrainCenterVertical()
            .setHeightConstraint(to: 5)
            .setCornerRadius(to: 2.5)

        self.scrubberControl
            .setBackgroundColor(to: Colors.accent)
            .setWidthConstraint(to: Self.SCRUBBER_DIAMETER)
            .setHeightConstraint(to: Self.SCRUBBER_DIAMETER)
            .constrainCenterVertical()
            .setCornerRadius(to: Self.SCRUBBER_DIAMETER / 2.0)
            .add(self.scrubberLabel)

        self.scrubberLabel
            .constrainCenterHorizontal(layoutGuide: .view)
            .constrainToOnTop(padding: 10.0, layoutGuide: .view)
            .setWidthConstraint(to: Self.DEFAULT_LABEL_WIDTH)
            .setHeightConstraint(to: Self.DEFAULT_LABEL_HEIGHT)
            .setCornerRadius(to: Self.DEFAULT_LABEL_HEIGHT * Self.LABEL_CORNER_RADIUS_HEIGHT_MULTIPLIER)
            .setBackgroundColor(to: Colors.fillForeground)
            .addShadow()
            .add(self.scrubberLabelText)

        self.scrubberLabelText
            .constrainCenterVertical(layoutGuide: .view)
            .constrainCenterHorizontal(layoutGuide: .view)
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
        DispatchQueue.main.async { [weak self] in
            self?.updateCirclePosition()
        }
    }

    // MARK: Functions

    @discardableResult
    public func setMin(to minValue: Double) -> Self {
        self.minValue = minValue
        if self.isTracking {
            self.redrawScrubberLabel()
        }
        return self
    }

    @discardableResult
    public func setMax(to maxValue: Double) -> Self {
        self.maxValue = maxValue
        if self.isTracking {
            self.redrawScrubberLabel()
        }
        return self
    }

    @discardableResult
    public func setRange(min: Double, max: Double) -> Self {
        self.minValue = min
        self.maxValue = max
        if self.isTracking {
            self.redrawScrubberLabel()
        }
        return self
    }

    public func setProgress(to proportion: Double) {
        self.progressProportion = min(1.0, max(0.0, proportion))
        if self.isTracking {
            self.redrawScrubberLabel()
        }
    }

    public func setValue(to value: Double) {
        guard let valueRange = self.valueRange else {
            return
        }
        guard valueRange.isGreaterThanZero() else {
            self.setProgress(to: 0.0)
            return
        }
        let clamped = min(self.maxValue, max(self.minValue, value))
        self.setProgress(to: (clamped - self.minValue) / valueRange)
    }

    @discardableResult
    public func setLabel(_ callback: ((_ proportion: Double, _ value: Double) -> String)?) -> Self {
        self.label = callback
        if self.isTracking {
            self.redrawScrubberLabel()
            self.activateScrubberLabel()
        }
        return self
    }

    @discardableResult
    public func setOnStartTracking(_ callback: (() -> Void)?) -> Self {
        self.onStartTracking = callback
        return self
    }

    @discardableResult
    public func setOnEndTracking(_ callback: (() -> Void)?) -> Self {
        self.onEndTracking = callback
        return self
    }

    @discardableResult
    public func setOnChange(_ callback: ((_ proportion: Double, _ value: Double) -> Void)?) -> Self {
        self.onChange = callback
        return self
    }

    @discardableResult
    public func setDisabled(to state: Bool) -> Self {
        self.isDisabled = state
        self.isTracking = false
        self.disableScrubberLabel()
        return self
    }

    private func redrawScrubberLabel() {
        guard let label = self.label else {
            return
        }
        self.scrubberLabelText.setText(to: label(self.progressProportion, self.value))
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
        self.scrubberLabel.setHidden(to: self.label == nil)
    }

    private func disableScrubberLabel() {
        self.scrubberLabel.setHidden(to: true)
    }

    private func onDrag(_ gesture: UIPanGestureRecognizer) {
        guard !self.isDisabled else {
            return
        }
        switch gesture.state {
        case .began:
            self.isTracking = true
            self.redrawScrubberLabel()
            self.activateScrubberLabel()
            self.onStartTracking?()
        case .changed:
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
            let newProgress = positionInLine / lineWidth
            self.progressProportion = min(1.0, max(0.0, newProgress))
            self.onChange?(self.progressProportion, self.value)
            self.redrawScrubberLabel()
        case .ended, .cancelled, .failed:
            self.isTracking = false
            self.disableScrubberLabel()
            self.onEndTracking?()
        default:
            break
        }
    }

    private func updateCirclePosition() {
        let timelineWidth = self.container.bounds.width - Self.SCRUBBER_DIAMETER
        let newPosition = self.progressProportion * timelineWidth + Self.SCRUBBER_DIAMETER / 2
        self.scrubberControl.center.x = newPosition
    }
}
