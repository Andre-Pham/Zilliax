//
//  Spinner.swift
//  https://github.com/Andre-Pham/Zilliax
//
//  Created by Andre Pham.
//

import UIKit

public class Spinner: View {
    // MARK: Static Properties

    private static let DEFAULT_SIZE = 32.0
    private static let DEFAULT_LINE_WIDTH = 4.0
    private static let ROTATION_KEY = "rotation"

    // MARK: Properties

    private let shapeLayer = CAShapeLayer()
    private var widthConstraint: NSLayoutConstraint!
    private var heightConstraint: NSLayoutConstraint!
    private var color = Colors.textDark
    private var traitRegistration: UITraitChangeRegistration? = nil

    // MARK: Overridden Functions

    public override func setup() {
        super.setup()

        (self.widthConstraint, self.heightConstraint) = self.setSizeConstraintValue(to: Self.DEFAULT_SIZE)

        self.shapeLayer.fillColor = UIColor.clear.cgColor
        self.shapeLayer.strokeColor = self.color.cgColor
        self.shapeLayer.lineWidth = Self.DEFAULT_LINE_WIDTH
        self.shapeLayer.lineCap = .round

        self.add(self.shapeLayer)

        self.traitRegistration = self.registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (spinner: Self, _) in
            spinner.updateColor()
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        self.updatePath()
    }

    public override func didMoveToWindow() {
        super.didMoveToWindow()
        if self.window != nil {
            self.startAnimating()
        } else {
            self.stopAnimating()
        }
    }

    // MARK: Functions

    @discardableResult
    public func startAnimating() -> Self {
        if self.shapeLayer.animation(forKey: Self.ROTATION_KEY) != nil {
            return self
        }
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = 0
        animation.toValue = Double.pi * 2.0
        animation.duration = 0.9
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        self.shapeLayer.add(animation, forKey: Self.ROTATION_KEY)
        return self
    }

    @discardableResult
    public func stopAnimating() -> Self {
        self.shapeLayer.removeAnimation(forKey: Self.ROTATION_KEY)
        return self
    }

    @discardableResult
    public func setColor(to color: UIColor) -> Self {
        self.color = color
        self.updateColor()
        return self
    }

    @discardableResult
    public func setLineWidth(to width: Double) -> Self {
        assert(width.isGreaterThanZero(), "Expected positive line width")
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.shapeLayer.lineWidth = width
        self.updatePath()
        CATransaction.commit()
        return self
    }

    @discardableResult
    public func setSize(to size: Double) -> Self {
        assert(size.isGreaterThanZero(), "Expected positive spinner size")
        self.widthConstraint.constant = size
        self.heightConstraint.constant = size
        self.setNeedsLayout()
        return self
    }

    private func updateColor() {
        let resolved = self.color.resolvedColor(with: self.traitCollection)
        self.shapeLayer.strokeColor = resolved.cgColor
    }

    private func updatePath() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.shapeLayer.frame = self.bounds
        let diameter = min(self.bounds.width, self.bounds.height)
        let radius = diameter / 2.0 - self.shapeLayer.lineWidth / 2.0
        if radius.isLessThanOrEqualTo(0) {
            self.shapeLayer.path = nil
            CATransaction.commit()
            return
        }
        let center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        let startAngle = -CGFloat.pi / 2.0
        let endAngle = startAngle + CGFloat.pi * 4 / 3
        let path = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )
        self.shapeLayer.path = path.cgPath
        CATransaction.commit()
    }
}
