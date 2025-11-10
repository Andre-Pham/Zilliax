//
//  UIView.swift
//  https://github.com/Andre-Pham/Zilliax
//
//  Created by Andre Pham.
//

import UIKit

extension UIView {
    public var opacity: Double {
        return self.alpha
    }

    public var layerOpacity: Double {
        return Double(self.layer.opacity)
    }

    /// The existing size of the view. Subclasses override this method to return a custom value based on the desired layout of any subviews.
    /// For example, UITextView returns the view size of its text, and UIImageView returns the size of the image it is currently displaying.
    public var contentBasedSize: CGSize {
        let maxSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        return self.sizeThatFits(maxSize)
    }

    public var widthConstraintConstant: Double {
        self.layoutIfNeeded()
        return self.frame.width
    }

    public var heightConstraintConstant: Double {
        self.layoutIfNeeded()
        return self.frame.height
    }

    public var hasSuperView: Bool {
        return self.superview != nil
    }

    // MARK: - Views

    @discardableResult
    public func add(_ subview: UIView) -> Self {
        self.addSubview(subview)
        return self
    }

    @discardableResult
    public func add(_ subview: UIView, at position: Int) -> Self {
        self.insertSubview(subview, at: position)
        return self
    }

    @discardableResult
    public func add(_ subview: UIView, above viewBelow: UIView) -> Self {
        self.insertSubview(subview, aboveSubview: viewBelow)
        return self
    }

    @discardableResult
    public func add(_ subview: UIView, below viewAbove: UIView) -> Self {
        self.insertSubview(subview, belowSubview: viewAbove)
        return self
    }

    @discardableResult
    public func addAsSubview(of view: UIView) -> Self {
        view.add(self)
        return self
    }

    @discardableResult
    public func addAsSubview(of view: UIView, at position: Int) -> Self {
        view.add(self, at: position)
        return self
    }

    @discardableResult
    public func addAsSubview(of view: UIView, above viewBelow: UIView) -> Self {
        view.add(self, above: viewBelow)
        return self
    }

    @discardableResult
    public func addAsSubview(of view: UIView, below viewAbove: UIView) -> Self {
        view.add(self, below: viewAbove)
        return self
    }

    @discardableResult
    public func add(_ layer: CALayer) -> Self {
        self.layer.addSublayer(layer)
        return self
    }

    @discardableResult
    public func remove() -> Self {
        self.removeFromSuperview()
        return self
    }

    @discardableResult
    public func removeSubviewsAndLayers() -> Self {
        for subview in self.subviews {
            subview.remove()
        }
        self.layer.sublayers?.forEach({ $0.removeFromSuperlayer() })
        return self
    }

    @discardableResult
    public func renderToUIImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, WindowContext.screenScale)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        self.layer.render(in: context)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        UIGraphicsEndImageContext()
        return image
    }

    /// Checks if this view is within another view's hierarchy of views.
    /// It iterates over the chain of superviews until it matches the target view or there are no more super views to check.
    /// - Parameters:
    ///   - target: The view who's hierarchy is being checked to contain this view
    /// - Returns: True if the target view's tree of subviews contains this view
    public func existsWithinHierarchy(of target: UIView) -> Bool {
        var viewToCheck: UIView? = self
        while let view = viewToCheck {
            if view === target {
                return true
            }
            viewToCheck = view.superview
        }
        return false
    }

    // MARK: - Frame

    @discardableResult
    public func useAutoLayout() -> Self {
        self.translatesAutoresizingMaskIntoConstraints = false
        return self
    }

    @discardableResult
    public func disableAutoLayout() -> Self {
        self.translatesAutoresizingMaskIntoConstraints = true
        return self
    }

    @discardableResult
    public func setFrame(to rect: CGRect) -> Self {
        self.frame = rect
        return self
    }

    @discardableResult
    public func setClipsToBounds(to state: Bool) -> Self {
        self.clipsToBounds = state
        return self
    }

    @discardableResult
    public func layoutIfNeededAnimated(withDuration: Double = 0.3) -> Self {
        UIView.animate(withDuration: withDuration, animations: {
            self.layoutIfNeeded()
        })
        return self
    }

    /// Adjusts a view's frame to be fully inside the screen's window bounds (assuming it's partially or fully off-screen)
    /// - Parameters:
    ///   - animationDuration: The animation duration for moving the view, or `nil` for no animation
    ///   - padding: The padding away from the screen's edges
    ///   - inset: The amount of inset for the screen's edges, e.g. 10 would treat the screen's width to be 20 less
    /// - Returns: An reference to the view's instance
    @discardableResult
    public func reframeIntoWindow(animationDuration: Double? = nil, padding: Double = 0.0, inset: Double = 0.0) -> Self {
        guard let window = WindowContext.window else {
            assertionFailure("Unable to find the key window")
            return self
        }
        // Ensure the view's layout is up to date.
        self.superview?.layoutIfNeeded()
        // Convert the view's frame to the window's coordinate system to get its position relative to the screen.
        let viewFrameInWindow = self.convert(self.bounds, to: window)
        // Screen bounds considering the safe area.
        let safeAreaInsets = window.safeAreaInsets
        let screenBounds = window.bounds.inset(by: safeAreaInsets)
        var newFrame = self.frame
        // Check and adjust for the right edge.
        if viewFrameInWindow.maxX.isGreater(than: screenBounds.maxX - inset) {
            let offsetX = viewFrameInWindow.maxX - screenBounds.maxX
            newFrame.origin.x -= offsetX
            newFrame.origin.x -= padding
        }
        // Check and adjust for the bottom edge.
        if viewFrameInWindow.maxY.isGreater(than: screenBounds.maxY - inset) {
            let offsetY = viewFrameInWindow.maxY - screenBounds.maxY
            newFrame.origin.y -= offsetY
            newFrame.origin.y -= padding
        }
        // Check and adjust for the left edge.
        if viewFrameInWindow.minX.isLess(than: screenBounds.minX + inset) {
            let offsetX = screenBounds.minX - viewFrameInWindow.minX
            newFrame.origin.x += offsetX
            newFrame.origin.x += padding
        }
        // Check and adjust for the top edge.
        if viewFrameInWindow.minY.isLess(than: screenBounds.minY + inset) {
            let offsetY = screenBounds.minY - viewFrameInWindow.minY
            newFrame.origin.y += offsetY
            newFrame.origin.y += padding
        }
        if let animationDuration {
            UIView.animate(withDuration: animationDuration) {
                self.frame = newFrame
            }
        } else {
            self.frame = newFrame
        }
        return self
    }

    // MARK: - Constraints

    public func matchWidthConstraintValue(
        to other: UIView? = nil,
        adjust: CGFloat = 0.0,
        respectSafeArea: Bool = true
    ) -> NSLayoutConstraint {
        assert(!self.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let target = other ?? self.superview else {
            fatalError("No constraint target found")
        }
        let anchor = respectSafeArea ? target.safeAreaLayoutGuide.widthAnchor : target.widthAnchor
        let constraint = self.widthAnchor.constraint(equalTo: anchor, constant: adjust)
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    public func matchWidthConstraint(to other: UIView? = nil, adjust: CGFloat = 0.0, respectSafeArea: Bool = true) -> Self {
        _ = self.matchWidthConstraintValue(to: other, adjust: adjust, respectSafeArea: respectSafeArea)
        return self
    }

    public func matchHeightConstraintValue(
        to other: UIView? = nil,
        adjust: CGFloat = 0.0,
        respectSafeArea: Bool = true
    ) -> NSLayoutConstraint {
        assert(!self.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let target = other ?? self.superview else {
            fatalError("No constraint target found")
        }
        let anchor = respectSafeArea ? target.safeAreaLayoutGuide.heightAnchor : target.heightAnchor
        let constraint = self.heightAnchor.constraint(equalTo: anchor, constant: adjust)
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    public func matchHeightConstraint(to other: UIView? = nil, adjust: CGFloat = 0.0, respectSafeArea: Bool = true) -> Self {
        _ = self.matchHeightConstraintValue(to: other, adjust: adjust, respectSafeArea: respectSafeArea)
        return self
    }

    public func setWidthConstraintValue(to width: Double) -> NSLayoutConstraint {
        assert(!self.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        let constraint = self.widthAnchor.constraint(equalToConstant: width)
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    public func setWidthConstraint(to width: Double) -> Self {
        _ = self.setWidthConstraintValue(to: width)
        return self
    }

    public func setHeightConstraintValue(to height: Double) -> NSLayoutConstraint {
        assert(!self.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        let constraint = self.heightAnchor.constraint(equalToConstant: height)
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    public func setHeightConstraint(to height: Double) -> Self {
        _ = self.setHeightConstraintValue(to: height)
        return self
    }

    public func setWidthConstraintValue(proportion: Double, useParentWidth: Bool = true) -> NSLayoutConstraint {
        assert(!self.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let parentView = self.superview else {
            fatalError("No constraint target found")
        }
        let constraint = self.widthAnchor.constraint(
            equalTo: useParentWidth ? parentView.widthAnchor : parentView.heightAnchor,
            multiplier: proportion
        )
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    public func setWidthConstraint(proportion: Double, useParentWidth: Bool = true) -> Self {
        _ = self.setWidthConstraintValue(proportion: proportion, useParentWidth: useParentWidth)
        return self
    }

    public func setHeightConstraintValue(proportion: Double, useParentHeight: Bool = true) -> NSLayoutConstraint {
        assert(!self.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let parentView = self.superview else {
            fatalError("No constraint target found")
        }
        let constraint = self.heightAnchor.constraint(
            equalTo: useParentHeight ? parentView.heightAnchor : parentView.widthAnchor,
            multiplier: proportion
        )
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    public func setHeightConstraint(proportion: Double, useParentHeight: Bool = true) -> Self {
        _ = self.setHeightConstraintValue(proportion: proportion, useParentHeight: useParentHeight)
        return self
    }

    public func setSizeConstraintValue(to size: Double) -> (width: NSLayoutConstraint, height: NSLayoutConstraint) {
        let width = self.setWidthConstraintValue(to: size)
        let height = self.setHeightConstraintValue(to: size)
        return (width, height)
    }

    @discardableResult
    public func setSizeConstraint(to size: Double) -> Self {
        _ = self.setSizeConstraintValue(to: size)
        return self
    }

    public func setSizeConstraintValue(
        proportion: Double,
        useParentWidth: Bool = true
    ) -> (width: NSLayoutConstraint, height: NSLayoutConstraint) {
        let width = self.setWidthConstraintValue(proportion: proportion, useParentWidth: useParentWidth)
        let height = self.setHeightConstraintValue(proportion: proportion, useParentHeight: !useParentWidth)
        return (width, height)
    }

    @discardableResult
    public func setSizeConstraint(proportion: Double, useParentWidth: Bool = true) -> Self {
        _ = self.setSizeConstraintValue(proportion: proportion, useParentWidth: useParentWidth)
        return self
    }

    public func constrainLeftValue(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        respectSafeArea: Bool = true,
        toContentLayoutGuide: Bool = false
    ) -> NSLayoutConstraint {
        assert(!self.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let target = other ?? self.superview else {
            fatalError("No constraint target found")
        }
        let anchor: NSLayoutXAxisAnchor = if toContentLayoutGuide, let scrollView = target as? UIScrollView {
            scrollView.contentLayoutGuide.leadingAnchor
        } else {
            respectSafeArea ? target.safeAreaLayoutGuide.leadingAnchor : target.leadingAnchor
        }
        let constraint = self.leadingAnchor.constraint(equalTo: anchor, constant: padding)
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    public func constrainLeft(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        respectSafeArea: Bool = true,
        toContentLayoutGuide: Bool = false
    ) -> Self {
        _ = self.constrainLeftValue(
            to: other,
            padding: padding,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        return self
    }

    public func constrainRightValue(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        respectSafeArea: Bool = true,
        toContentLayoutGuide: Bool = false
    ) -> NSLayoutConstraint {
        assert(!self.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let target = other ?? self.superview else {
            fatalError("No constraint target found")
        }
        let anchor: NSLayoutXAxisAnchor = if toContentLayoutGuide, let scrollView = target as? UIScrollView {
            scrollView.contentLayoutGuide.trailingAnchor
        } else {
            respectSafeArea ? target.safeAreaLayoutGuide.trailingAnchor : target.trailingAnchor
        }
        let constraint = self.trailingAnchor.constraint(equalTo: anchor, constant: -padding)
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    public func constrainRight(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        respectSafeArea: Bool = true,
        toContentLayoutGuide: Bool = false
    ) -> Self {
        _ = self.constrainRightValue(
            to: other,
            padding: padding,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        return self
    }

    public func constrainTopValue(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        respectSafeArea: Bool = true,
        toContentLayoutGuide: Bool = false
    ) -> NSLayoutConstraint {
        assert(!self.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let target = other ?? self.superview else {
            fatalError("No constraint target found")
        }
        let anchor: NSLayoutYAxisAnchor = if toContentLayoutGuide, let scrollView = target as? UIScrollView {
            scrollView.contentLayoutGuide.topAnchor
        } else {
            respectSafeArea ? target.safeAreaLayoutGuide.topAnchor : target.topAnchor
        }
        let constraint = self.topAnchor.constraint(equalTo: anchor, constant: padding)
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    public func constrainTop(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        respectSafeArea: Bool = true,
        toContentLayoutGuide: Bool = false
    ) -> Self {
        _ = self.constrainTopValue(
            to: other,
            padding: padding,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        return self
    }

    public func constrainBottomValue(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        respectSafeArea: Bool = true,
        toContentLayoutGuide: Bool = false
    ) -> NSLayoutConstraint {
        assert(!self.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let target = other ?? self.superview else {
            fatalError("No constraint target found")
        }
        let anchor: NSLayoutYAxisAnchor = if toContentLayoutGuide, let scrollView = target as? UIScrollView {
            scrollView.contentLayoutGuide.bottomAnchor
        } else {
            respectSafeArea ? target.safeAreaLayoutGuide.bottomAnchor : target.bottomAnchor
        }
        let constraint = self.bottomAnchor.constraint(equalTo: anchor, constant: -padding)
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    public func constrainBottom(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        respectSafeArea: Bool = true,
        toContentLayoutGuide: Bool = false
    ) -> Self {
        _ = self.constrainBottomValue(
            to: other,
            padding: padding,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        return self
    }

    public func constrainHorizontalValue(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        respectSafeArea: Bool = true,
        toContentLayoutGuide: Bool = false
    ) -> (left: NSLayoutConstraint, right: NSLayoutConstraint) {
        let left = self.constrainLeftValue(
            to: other,
            padding: padding,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        let right = self.constrainRightValue(
            to: other,
            padding: padding,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        return (left: left, right: right)
    }

    @discardableResult
    public func constrainHorizontal(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        respectSafeArea: Bool = true,
        toContentLayoutGuide: Bool = false
    ) -> Self {
        _ = self.constrainHorizontalValue(
            to: other,
            padding: padding,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        return self
    }

    public func constrainVerticalValue(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        respectSafeArea: Bool = true,
        toContentLayoutGuide: Bool = false
    ) -> (top: NSLayoutConstraint, bottom: NSLayoutConstraint) {
        let top = self.constrainTopValue(
            to: other,
            padding: padding,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        let bottom = self.constrainBottomValue(
            to: other,
            padding: padding,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        return (top: top, bottom: bottom)
    }

    @discardableResult
    public func constrainVertical(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        respectSafeArea: Bool = true,
        toContentLayoutGuide: Bool = false
    ) -> Self {
        _ = self.constrainVerticalValue(
            to: other,
            padding: padding,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        return self
    }

    public func constrainAllSidesValue(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        respectSafeArea: Bool = true,
        toContentLayoutGuide: Bool = false
    ) -> (left: NSLayoutConstraint, right: NSLayoutConstraint, top: NSLayoutConstraint, bottom: NSLayoutConstraint) {
        let horizontal = self.constrainHorizontalValue(
            to: other,
            padding: padding,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        let vertical = self.constrainVerticalValue(
            to: other,
            padding: padding,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        return (left: horizontal.left, right: horizontal.right, top: vertical.top, bottom: vertical.bottom)
    }

    @discardableResult
    public func constrainAllSides(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        respectSafeArea: Bool = true,
        toContentLayoutGuide: Bool = false
    ) -> Self {
        _ = self.constrainAllSidesValue(
            to: other,
            padding: padding,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        return self
    }

    public func constrainToUnderneathValue(
        of other: UIView? = nil,
        padding: CGFloat = 0.0,
        respectSafeArea: Bool = true
    ) -> NSLayoutConstraint {
        assert(!self.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let target = other ?? self.superview else {
            fatalError("No constraint target found")
        }
        let anchor = respectSafeArea ? target.safeAreaLayoutGuide.bottomAnchor : target.bottomAnchor
        let constraint = self.topAnchor.constraint(equalTo: anchor, constant: padding)
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    public func constrainToUnderneath(of other: UIView? = nil, padding: CGFloat = 0.0, respectSafeArea: Bool = true) -> Self {
        _ = self.constrainToUnderneathValue(of: other, padding: padding, respectSafeArea: respectSafeArea)
        return self
    }

    public func constrainToOnTopValue(of other: UIView? = nil, padding: CGFloat = 0.0, respectSafeArea: Bool = true) -> NSLayoutConstraint {
        assert(!self.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let target = other ?? self.superview else {
            fatalError("No constraint target found")
        }
        let anchor = respectSafeArea ? target.safeAreaLayoutGuide.topAnchor : target.topAnchor
        let constraint = self.bottomAnchor.constraint(equalTo: anchor, constant: -padding)
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    public func constrainToOnTop(of other: UIView? = nil, padding: CGFloat = 0.0, respectSafeArea: Bool = true) -> Self {
        _ = self.constrainToOnTopValue(of: other, padding: padding, respectSafeArea: respectSafeArea)
        return self
    }

    public func constrainToRightSideValue(
        of other: UIView? = nil,
        padding: CGFloat = 0.0,
        respectSafeArea: Bool = true
    ) -> NSLayoutConstraint {
        assert(!self.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let target = other ?? self.superview else {
            fatalError("No constraint target found")
        }
        let anchor = respectSafeArea ? target.safeAreaLayoutGuide.rightAnchor : target.rightAnchor
        let constraint = self.leftAnchor.constraint(equalTo: anchor, constant: padding)
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    public func constrainToRightSide(of other: UIView? = nil, padding: CGFloat = 0.0, respectSafeArea: Bool = true) -> Self {
        _ = self.constrainToRightSideValue(of: other, padding: padding, respectSafeArea: respectSafeArea)
        return self
    }

    public func constrainToLeftSideValue(
        of other: UIView? = nil,
        padding: CGFloat = 0.0,
        respectSafeArea: Bool = true
    ) -> NSLayoutConstraint {
        assert(!self.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let target = other ?? self.superview else {
            fatalError("No constraint target found")
        }
        let anchor = respectSafeArea ? target.safeAreaLayoutGuide.leftAnchor : target.leftAnchor
        let constraint = self.rightAnchor.constraint(equalTo: anchor, constant: -padding)
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    public func constrainToLeftSide(of other: UIView? = nil, padding: CGFloat = 0.0, respectSafeArea: Bool = true) -> Self {
        _ = self.constrainToLeftSideValue(of: other, padding: padding, respectSafeArea: respectSafeArea)
        return self
    }

    public func constrainCenterVerticalValue(to other: UIView? = nil, respectSafeArea: Bool = true) -> NSLayoutConstraint {
        assert(!self.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let target = other ?? self.superview else {
            fatalError("No constraint target found")
        }
        let anchor = respectSafeArea ? target.safeAreaLayoutGuide.centerYAnchor : target.centerYAnchor
        let constraint = self.centerYAnchor.constraint(equalTo: anchor)
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    public func constrainCenterVertical(to other: UIView? = nil, respectSafeArea: Bool = true) -> Self {
        _ = self.constrainCenterVerticalValue(to: other, respectSafeArea: respectSafeArea)
        return self
    }

    public func constrainCenterHorizontalValue(to other: UIView? = nil, respectSafeArea: Bool = true) -> NSLayoutConstraint {
        assert(!self.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let target = other ?? self.superview else {
            fatalError("No constraint target found")
        }
        let anchor = respectSafeArea ? target.safeAreaLayoutGuide.centerXAnchor : target.centerXAnchor
        let constraint = self.centerXAnchor.constraint(equalTo: anchor)
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    public func constrainCenterHorizontal(to other: UIView? = nil, respectSafeArea: Bool = true) -> Self {
        _ = self.constrainCenterHorizontalValue(to: other, respectSafeArea: respectSafeArea)
        return self
    }

    public func constrainCenterValue(
        to other: UIView? = nil,
        respectSafeArea: Bool = true
    ) -> (vertical: NSLayoutConstraint, horizontal: NSLayoutConstraint) {
        let vertical = self.constrainCenterVerticalValue(to: other, respectSafeArea: respectSafeArea)
        let horizontal = self.constrainCenterHorizontalValue(to: other, respectSafeArea: respectSafeArea)
        return (vertical: vertical, horizontal: horizontal)
    }

    @discardableResult
    public func constrainCenter(to other: UIView? = nil, respectSafeArea: Bool = true) -> Self {
        _ = self.constrainCenterValue(to: other, respectSafeArea: respectSafeArea)
        return self
    }

    public func constrainCenterLeftValue(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        respectSafeArea: Bool = true
    ) -> NSLayoutConstraint {
        assert(!self.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let target = other ?? self.superview else {
            fatalError("No constraint target found")
        }
        let anchor = respectSafeArea ? target.safeAreaLayoutGuide.leftAnchor : target.leftAnchor
        let constraint = self.centerXAnchor.constraint(equalTo: anchor, constant: padding)
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    public func constrainCenterLeft(to other: UIView? = nil, padding: CGFloat = 0.0, respectSafeArea: Bool = true) -> Self {
        _ = self.constrainCenterLeftValue(to: other, padding: padding, respectSafeArea: respectSafeArea)
        return self
    }

    public func constrainCenterRightValue(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        respectSafeArea: Bool = true
    ) -> NSLayoutConstraint {
        assert(!self.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let target = other ?? self.superview else {
            fatalError("No constraint target found")
        }
        let anchor = respectSafeArea ? target.safeAreaLayoutGuide.rightAnchor : target.rightAnchor
        let constraint = self.centerXAnchor.constraint(equalTo: anchor, constant: -padding)
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    public func constrainCenterRight(to other: UIView? = nil, padding: CGFloat = 0.0, respectSafeArea: Bool = true) -> Self {
        _ = self.constrainCenterRightValue(to: other, padding: padding, respectSafeArea: respectSafeArea)
        return self
    }

    public func constrainCenterTopValue(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        respectSafeArea: Bool = true
    ) -> NSLayoutConstraint {
        assert(!self.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let target = other ?? self.superview else {
            fatalError("No constraint target found")
        }
        let anchor = respectSafeArea ? target.safeAreaLayoutGuide.topAnchor : target.topAnchor
        let constraint = self.centerYAnchor.constraint(equalTo: anchor, constant: padding)
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    public func constrainCenterTop(to other: UIView? = nil, padding: CGFloat = 0.0, respectSafeArea: Bool = true) -> Self {
        _ = self.constrainCenterTopValue(to: other, padding: padding, respectSafeArea: respectSafeArea)
        return self
    }

    public func constrainCenterBottomValue(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        respectSafeArea: Bool = true
    ) -> NSLayoutConstraint {
        assert(!self.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let target = other ?? self.superview else {
            fatalError("No constraint target found")
        }
        let anchor = respectSafeArea ? target.safeAreaLayoutGuide.bottomAnchor : target.bottomAnchor
        let constraint = self.centerYAnchor.constraint(equalTo: anchor, constant: -padding)
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    public func constrainCenterBottom(to other: UIView? = nil, padding: CGFloat = 0.0, respectSafeArea: Bool = true) -> Self {
        _ = self.constrainCenterBottomValue(to: other, padding: padding, respectSafeArea: respectSafeArea)
        return self
    }

    public func constrainBetweenVerticalValue(
        topView: UIView? = nil,
        isBeneathTopView: Bool = true,
        bottomView: UIView? = nil,
        isAboveBottomView: Bool = true,
        topPadding: Double = 0.0,
        bottomPadding: Double = 0.0,
        respectSafeArea: Bool = true
    ) -> NSLayoutConstraint {
        assert(!self.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let topView = topView ?? self.superview else {
            fatalError("No top constraint target found")
        }
        guard let bottomView = bottomView ?? self.superview else {
            fatalError("No bottom constraint target found")
        }
        guard let superview = self.superview else {
            fatalError("No superview found")
        }
        let guide = UIView().useAutoLayout()
        superview.add(guide)
        if isBeneathTopView {
            guide.constrainToUnderneath(of: topView, padding: topPadding, respectSafeArea: respectSafeArea)
        } else {
            guide.constrainTop(to: topView, padding: topPadding, respectSafeArea: respectSafeArea)
        }
        if isAboveBottomView {
            guide.constrainToOnTop(of: bottomView, padding: bottomPadding, respectSafeArea: respectSafeArea)
        } else {
            guide.constrainBottom(to: bottomView, padding: bottomPadding, respectSafeArea: respectSafeArea)
        }
        return self.constrainCenterVerticalValue(to: guide, respectSafeArea: respectSafeArea)
    }

    @discardableResult
    public func constrainBetweenVertical(
        topView: UIView? = nil,
        isBeneathTopView: Bool = true,
        bottomView: UIView? = nil,
        isAboveBottomView: Bool = true,
        topPadding: Double = 0.0,
        bottomPadding: Double = 0.0,
        respectSafeArea: Bool = true
    ) -> Self {
        _ = self.constrainBetweenVerticalValue(
            topView: topView,
            isBeneathTopView: isBeneathTopView,
            bottomView: bottomView,
            isAboveBottomView: isAboveBottomView,
            topPadding: topPadding,
            bottomPadding: bottomPadding,
            respectSafeArea: respectSafeArea
        )
        return self
    }

    public func constrainBetweenHorizontalValue(
        leftView: UIView? = nil,
        isBesideLeftView: Bool = true,
        rightView: UIView? = nil,
        isBesideRightView: Bool = true,
        leftPadding: Double = 0.0,
        rightPadding: Double = 0.0,
        respectSafeArea: Bool = true
    ) -> NSLayoutConstraint {
        assert(!self.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let leftView = leftView ?? self.superview else {
            fatalError("No left constraint target found")
        }
        guard let rightView = rightView ?? self.superview else {
            fatalError("No right constraint target found")
        }
        guard let superview = self.superview else {
            fatalError("No superview found")
        }
        let guide = UIView().useAutoLayout()
        superview.add(guide)
        if isBesideLeftView {
            guide.constrainToRightSide(of: leftView, padding: leftPadding, respectSafeArea: respectSafeArea)
        } else {
            guide.constrainLeft(to: leftView, padding: leftPadding, respectSafeArea: respectSafeArea)
        }
        if isBesideRightView {
            guide.constrainToLeftSide(of: rightView, padding: rightPadding, respectSafeArea: respectSafeArea)
        } else {
            guide.constrainRight(to: rightView, padding: rightPadding, respectSafeArea: respectSafeArea)
        }
        return self.constrainCenterHorizontalValue(to: guide, respectSafeArea: respectSafeArea)
    }

    @discardableResult
    public func constrainBetweenHorizontal(
        leftView: UIView? = nil,
        isBesideLeftView: Bool = true,
        rightView: UIView? = nil,
        isBesideRightView: Bool = true,
        leftPadding: Double = 0.0,
        rightPadding: Double = 0.0,
        respectSafeArea: Bool = true
    ) -> Self {
        _ = self.constrainBetweenHorizontalValue(
            leftView: leftView,
            isBesideLeftView: isBesideLeftView,
            rightView: rightView,
            isBesideRightView: isBesideRightView,
            leftPadding: leftPadding,
            rightPadding: rightPadding,
            respectSafeArea: respectSafeArea
        )
        return self
    }

    public func constrainHorizontalByProportionValue(
        to other: UIView? = nil,
        proportionFromLeft: Double,
        padding: CGFloat = 0.0
    ) -> NSLayoutConstraint {
        assert(!self.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let target = other ?? self.superview else {
            fatalError("No constraint target found")
        }
        let guide = UIView().useAutoLayout()
        target.add(guide)
        guide
            .constrainLeft(respectSafeArea: false)
            .setWidthConstraint(proportion: proportionFromLeft)
        return self.constrainCenterRightValue(to: guide, padding: padding, respectSafeArea: false)
    }

    @discardableResult
    public func constrainHorizontalByProportion(
        to other: UIView? = nil,
        proportionFromLeft: Double,
        padding: CGFloat = 0.0
    ) -> Self {
        _ = self.constrainHorizontalByProportionValue(
            to: other,
            proportionFromLeft: proportionFromLeft,
            padding: padding
        )
        return self
    }

    public func constrainVerticalByProportionValue(
        to other: UIView? = nil,
        proportionFromTop: Double,
        padding: CGFloat = 0.0
    ) -> NSLayoutConstraint {
        assert(!self.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let target = other ?? self.superview else {
            fatalError("No constraint target found")
        }
        let guide = UIView().useAutoLayout()
        target.add(guide)
        guide
            .constrainTop(respectSafeArea: false)
            .setHeightConstraint(proportion: proportionFromTop)
        return self.constrainCenterBottomValue(to: guide, padding: padding, respectSafeArea: false)
    }

    @discardableResult
    public func constrainVerticalByProportion(
        to other: UIView? = nil,
        proportionFromTop: Double,
        padding: CGFloat = 0.0
    ) -> Self {
        _ = self.constrainVerticalByProportionValue(
            to: other,
            proportionFromTop: proportionFromTop,
            padding: padding
        )
        return self
    }

    public func matchWidthConstrainCenterValue(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        maxWidth: CGFloat,
        respectSafeArea: Bool = true,
        toContentLayoutGuide: Bool = false
    ) -> (
        maxLeft: NSLayoutConstraint,
        maxRight: NSLayoutConstraint,
        center: NSLayoutConstraint,
        maxWidth: NSLayoutConstraint,
        matchWidth: NSLayoutConstraint
    ) {
        let maxLeftConstraint = self.constrainMaxLeftValue(
            to: other,
            padding: padding,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        let maxRightConstraint = self.constrainMaxRightValue(
            to: other,
            padding: padding,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        let centerConstraint = self.constrainCenterHorizontalValue(to: other, respectSafeArea: respectSafeArea)
        let maxWidthConstraint = self.setMaxWidthConstraintValue(to: maxWidth)
        guard let target = other ?? self.superview else {
            fatalError("No constraint target found")
        }
        let anchor = respectSafeArea ? target.safeAreaLayoutGuide.widthAnchor : target.widthAnchor
        let matchWidthConstraint = self.widthAnchor.constraint(equalTo: anchor)
        matchWidthConstraint.priority = .defaultHigh
        matchWidthConstraint.isActive = true
        return (
            maxLeft: maxLeftConstraint,
            maxRight: maxRightConstraint,
            center: centerConstraint,
            maxWidth: maxWidthConstraint,
            matchWidth: matchWidthConstraint
        )
    }

    @discardableResult
    public func matchWidthConstrainCenter(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        maxWidth: CGFloat,
        respectSafeArea: Bool = true,
        toContentLayoutGuide: Bool = false
    ) -> Self {
        _ = self.matchWidthConstrainCenterValue(
            to: other,
            padding: padding,
            maxWidth: maxWidth,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        return self
    }

    public func matchWidthConstrainLeftValue(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        maxWidth: CGFloat,
        respectSafeArea: Bool = true,
        toContentLayoutGuide: Bool = false
    ) -> (
        left: NSLayoutConstraint,
        maxRight: NSLayoutConstraint,
        maxWidth: NSLayoutConstraint,
        matchWidth: NSLayoutConstraint
    ) {
        let leftConstraint = self.constrainLeftValue(
            to: other,
            padding: padding,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        let maxRightConstraint = self.constrainMaxRightValue(
            to: other,
            padding: padding,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        let maxWidthConstraint = self.setMaxWidthConstraintValue(to: maxWidth)
        guard let target = other ?? self.superview else {
            fatalError("No constraint target found")
        }
        let anchor = respectSafeArea ? target.safeAreaLayoutGuide.widthAnchor : target.widthAnchor
        let matchWidthConstraint = self.widthAnchor.constraint(equalTo: anchor)
        matchWidthConstraint.priority = .defaultHigh
        matchWidthConstraint.isActive = true
        return (
            left: leftConstraint,
            maxRight: maxRightConstraint,
            maxWidth: maxWidthConstraint,
            matchWidth: matchWidthConstraint
        )
    }

    @discardableResult
    public func matchWidthConstrainLeft(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        maxWidth: CGFloat,
        respectSafeArea: Bool = true,
        toContentLayoutGuide: Bool = false
    ) -> Self {
        _ = self.matchWidthConstrainLeftValue(
            to: other,
            padding: padding,
            maxWidth: maxWidth,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        return self
    }

    public func matchWidthConstrainRightValue(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        maxWidth: CGFloat,
        respectSafeArea: Bool = true,
        toContentLayoutGuide: Bool = false
    ) -> (
        maxLeft: NSLayoutConstraint,
        right: NSLayoutConstraint,
        maxWidth: NSLayoutConstraint,
        matchWidth: NSLayoutConstraint
    ) {
        let maxLeftConstraint = self.constrainMaxLeftValue(
            to: other,
            padding: padding,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        let rightConstraint = self.constrainRightValue(
            to: other,
            padding: padding,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        let maxWidthConstraint = self.setMaxWidthConstraintValue(to: maxWidth)
        guard let target = other ?? self.superview else {
            fatalError("No constraint target found")
        }
        let anchor = respectSafeArea ? target.safeAreaLayoutGuide.widthAnchor : target.widthAnchor
        let matchWidthConstraint = self.widthAnchor.constraint(equalTo: anchor)
        matchWidthConstraint.priority = .defaultHigh
        matchWidthConstraint.isActive = true
        return (
            maxLeft: maxLeftConstraint,
            right: rightConstraint,
            maxWidth: maxWidthConstraint,
            matchWidth: matchWidthConstraint
        )
    }

    @discardableResult
    public func matchWidthConstrainRight(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        maxWidth: CGFloat,
        respectSafeArea: Bool = true,
        toContentLayoutGuide: Bool = false
    ) -> Self {
        _ = self.matchWidthConstrainRightValue(
            to: other,
            padding: padding,
            maxWidth: maxWidth,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        return self
    }

    public func matchHeightConstrainCenterValue(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        maxHeight: CGFloat,
        respectSafeArea: Bool = true,
        toContentLayoutGuide: Bool = false
    ) -> (
        maxTop: NSLayoutConstraint,
        maxBottom: NSLayoutConstraint,
        center: NSLayoutConstraint,
        maxHeight: NSLayoutConstraint,
        matchHeight: NSLayoutConstraint
    ) {
        let maxTopConstraint = self.constrainMaxTopValue(
            to: other,
            padding: padding,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        let maxBottomConstraint = self.constrainMaxBottomValue(
            to: other,
            padding: padding,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        let centerConstraint = self.constrainCenterVerticalValue(to: other, respectSafeArea: respectSafeArea)
        let maxHeightConstraint = self.setMaxHeightConstraintValue(to: maxHeight)
        guard let target = other ?? self.superview else {
            fatalError("No constraint target found")
        }
        let anchor = respectSafeArea ? target.safeAreaLayoutGuide.heightAnchor : target.heightAnchor
        let matchHeightConstraint = self.heightAnchor.constraint(equalTo: anchor)
        matchHeightConstraint.priority = .defaultHigh
        matchHeightConstraint.isActive = true
        return (
            maxTop: maxTopConstraint,
            maxBottom: maxBottomConstraint,
            center: centerConstraint,
            maxHeight: maxHeightConstraint,
            matchHeight: matchHeightConstraint
        )
    }

    @discardableResult
    public func matchHeightConstrainCenter(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        maxHeight: CGFloat,
        respectSafeArea: Bool = true,
        toContentLayoutGuide: Bool = false
    ) -> Self {
        _ = self.matchHeightConstrainCenterValue(
            to: other,
            padding: padding,
            maxHeight: maxHeight,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        return self
    }

    public func matchHeightConstrainTopValue(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        maxHeight: CGFloat,
        respectSafeArea: Bool = true,
        toContentLayoutGuide: Bool = false
    ) -> (
        top: NSLayoutConstraint,
        maxBottom: NSLayoutConstraint,
        maxHeight: NSLayoutConstraint,
        matchHeight: NSLayoutConstraint
    ) {
        let topConstraint = self.constrainTopValue(
            to: other,
            padding: padding,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        let maxBottomConstraint = self.constrainMaxBottomValue(
            to: other,
            padding: padding,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        let maxHeightConstraint = self.setMaxHeightConstraintValue(to: maxHeight)
        guard let target = other ?? self.superview else {
            fatalError("No constraint target found")
        }
        let anchor = respectSafeArea ? target.safeAreaLayoutGuide.heightAnchor : target.heightAnchor
        let matchHeightConstraint = self.heightAnchor.constraint(equalTo: anchor)
        matchHeightConstraint.priority = .defaultHigh
        matchHeightConstraint.isActive = true
        return (
            top: topConstraint,
            maxBottom: maxBottomConstraint,
            maxHeight: maxHeightConstraint,
            matchHeight: matchHeightConstraint
        )
    }

    @discardableResult
    public func matchHeightConstrainTop(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        maxHeight: CGFloat,
        respectSafeArea: Bool = true,
        toContentLayoutGuide: Bool = false
    ) -> Self {
        _ = self.matchHeightConstrainTopValue(
            to: other,
            padding: padding,
            maxHeight: maxHeight,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        return self
    }

    public func matchHeightConstrainBottomValue(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        maxHeight: CGFloat,
        respectSafeArea: Bool = true,
        toContentLayoutGuide: Bool = false
    ) -> (
        maxTop: NSLayoutConstraint,
        bottom: NSLayoutConstraint,
        maxHeight: NSLayoutConstraint,
        matchHeight: NSLayoutConstraint
    ) {
        let maxTopConstraint = self.constrainMaxTopValue(
            to: other,
            padding: padding,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        let bottomConstraint = self.constrainBottomValue(
            to: other,
            padding: padding,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        let maxHeightConstraint = self.setMaxHeightConstraintValue(to: maxHeight)
        guard let target = other ?? self.superview else {
            fatalError("No constraint target found")
        }
        let anchor = respectSafeArea ? target.safeAreaLayoutGuide.heightAnchor : target.heightAnchor
        let matchHeightConstraint = self.heightAnchor.constraint(equalTo: anchor)
        matchHeightConstraint.priority = .defaultHigh
        matchHeightConstraint.isActive = true
        return (
            maxTop: maxTopConstraint,
            bottom: bottomConstraint,
            maxHeight: maxHeightConstraint,
            matchHeight: matchHeightConstraint
        )
    }

    @discardableResult
    public func matchHeightConstrainBottom(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        maxHeight: CGFloat,
        respectSafeArea: Bool = true,
        toContentLayoutGuide: Bool = false
    ) -> Self {
        _ = self.matchHeightConstrainBottomValue(
            to: other,
            padding: padding,
            maxHeight: maxHeight,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        return self
    }

    public func setMinWidthConstraintValue(to width: Double) -> NSLayoutConstraint {
        assert(!self.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        let constraint = self.widthAnchor.constraint(greaterThanOrEqualToConstant: width)
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    public func setMinWidthConstraint(to width: Double) -> Self {
        _ = self.setMinWidthConstraintValue(to: width)
        return self
    }

    public func setMinHeightConstraintValue(to height: Double) -> NSLayoutConstraint {
        assert(!self.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        let constraint = self.heightAnchor.constraint(greaterThanOrEqualToConstant: height)
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    public func setMinHeightConstraint(to height: Double) -> Self {
        _ = self.setMinHeightConstraintValue(to: height)
        return self
    }

    public func setMaxWidthConstraintValue(to width: Double) -> NSLayoutConstraint {
        assert(!self.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        let constraint = self.widthAnchor.constraint(lessThanOrEqualToConstant: width)
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    public func setMaxWidthConstraint(to width: Double) -> Self {
        _ = self.setMaxWidthConstraintValue(to: width)
        return self
    }

    public func setMaxHeightConstraintValue(to height: Double) -> NSLayoutConstraint {
        assert(!self.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        let constraint = self.heightAnchor.constraint(lessThanOrEqualToConstant: height)
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    public func setMaxHeightConstraint(to height: Double) -> Self {
        _ = self.setMaxHeightConstraintValue(to: height)
        return self
    }

    public func constrainMinLeftValue(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        respectSafeArea: Bool = true,
        toContentLayoutGuide: Bool = false
    ) -> NSLayoutConstraint {
        assert(!self.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let target = other ?? self.superview else {
            fatalError("No constraint target found")
        }
        let anchor: NSLayoutXAxisAnchor = if toContentLayoutGuide, let scrollView = target as? UIScrollView {
            scrollView.contentLayoutGuide.leadingAnchor
        } else {
            respectSafeArea ? target.safeAreaLayoutGuide.leadingAnchor : target.leadingAnchor
        }
        let constraint = self.leadingAnchor.constraint(lessThanOrEqualTo: anchor, constant: padding)
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    public func constrainMinLeft(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        respectSafeArea: Bool = true,
        toContentLayoutGuide: Bool = false
    ) -> Self {
        _ = self.constrainMinLeftValue(
            to: other,
            padding: padding,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        return self
    }

    public func constrainMaxLeftValue(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        respectSafeArea: Bool = true,
        toContentLayoutGuide: Bool = false
    ) -> NSLayoutConstraint {
        assert(!self.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let target = other ?? self.superview else {
            fatalError("No constraint target found")
        }
        let anchor: NSLayoutXAxisAnchor = if toContentLayoutGuide, let scrollView = target as? UIScrollView {
            scrollView.contentLayoutGuide.leadingAnchor
        } else {
            respectSafeArea ? target.safeAreaLayoutGuide.leadingAnchor : target.leadingAnchor
        }
        let constraint = self.leadingAnchor.constraint(greaterThanOrEqualTo: anchor, constant: padding)
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    public func constrainMaxLeft(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        respectSafeArea: Bool = true,
        toContentLayoutGuide: Bool = false
    ) -> Self {
        _ = self.constrainMaxLeftValue(
            to: other,
            padding: padding,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        return self
    }

    public func constrainMinRightValue(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        respectSafeArea: Bool = true,
        toContentLayoutGuide: Bool = false
    ) -> NSLayoutConstraint {
        assert(!self.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let target = other ?? self.superview else {
            fatalError("No constraint target found")
        }
        let anchor: NSLayoutXAxisAnchor = if toContentLayoutGuide, let scrollView = target as? UIScrollView {
            scrollView.contentLayoutGuide.trailingAnchor
        } else {
            respectSafeArea ? target.safeAreaLayoutGuide.trailingAnchor : target.trailingAnchor
        }
        let constraint = self.trailingAnchor.constraint(greaterThanOrEqualTo: anchor, constant: -padding)
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    public func constrainMinRight(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        respectSafeArea: Bool = true,
        toContentLayoutGuide: Bool = false
    ) -> Self {
        _ = self.constrainMinRightValue(
            to: other,
            padding: padding,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        return self
    }

    public func constrainMaxRightValue(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        respectSafeArea: Bool = true,
        toContentLayoutGuide: Bool = false
    ) -> NSLayoutConstraint {
        assert(!self.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let target = other ?? self.superview else {
            fatalError("No constraint target found")
        }
        let anchor: NSLayoutXAxisAnchor = if toContentLayoutGuide, let scrollView = target as? UIScrollView {
            scrollView.contentLayoutGuide.trailingAnchor
        } else {
            respectSafeArea ? target.safeAreaLayoutGuide.trailingAnchor : target.trailingAnchor
        }
        let constraint = self.trailingAnchor.constraint(lessThanOrEqualTo: anchor, constant: -padding)
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    public func constrainMaxRight(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        respectSafeArea: Bool = true,
        toContentLayoutGuide: Bool = false
    ) -> Self {
        _ = self.constrainMaxRightValue(
            to: other,
            padding: padding,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        return self
    }

    public func constrainMinTopValue(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        respectSafeArea: Bool = true,
        toContentLayoutGuide: Bool = false
    ) -> NSLayoutConstraint {
        assert(!self.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let target = other ?? self.superview else {
            fatalError("No constraint target found")
        }
        let anchor: NSLayoutYAxisAnchor = if toContentLayoutGuide, let scrollView = target as? UIScrollView {
            scrollView.contentLayoutGuide.topAnchor
        } else {
            respectSafeArea ? target.safeAreaLayoutGuide.topAnchor : target.topAnchor
        }
        let constraint = self.topAnchor.constraint(lessThanOrEqualTo: anchor, constant: padding)
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    public func constrainMinTop(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        respectSafeArea: Bool = true,
        toContentLayoutGuide: Bool = false
    ) -> Self {
        _ = self.constrainMinTopValue(
            to: other,
            padding: padding,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        return self
    }

    public func constrainMaxTopValue(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        respectSafeArea: Bool = true,
        toContentLayoutGuide: Bool = false
    ) -> NSLayoutConstraint {
        assert(!self.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let target = other ?? self.superview else {
            fatalError("No constraint target found")
        }
        let anchor: NSLayoutYAxisAnchor = if toContentLayoutGuide, let scrollView = target as? UIScrollView {
            scrollView.contentLayoutGuide.topAnchor
        } else {
            respectSafeArea ? target.safeAreaLayoutGuide.topAnchor : target.topAnchor
        }
        let constraint = self.topAnchor.constraint(greaterThanOrEqualTo: anchor, constant: padding)
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    public func constrainMaxTop(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        respectSafeArea: Bool = true,
        toContentLayoutGuide: Bool = false
    ) -> Self {
        _ = self.constrainMaxTopValue(
            to: other,
            padding: padding,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        return self
    }

    public func constrainMinBottomValue(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        respectSafeArea: Bool = true,
        toContentLayoutGuide: Bool = false
    ) -> NSLayoutConstraint {
        assert(!self.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let target = other ?? self.superview else {
            fatalError("No constraint target found")
        }
        let anchor: NSLayoutYAxisAnchor = if toContentLayoutGuide, let scrollView = target as? UIScrollView {
            scrollView.contentLayoutGuide.bottomAnchor
        } else {
            respectSafeArea ? target.safeAreaLayoutGuide.bottomAnchor : target.bottomAnchor
        }
        let constraint = self.bottomAnchor.constraint(greaterThanOrEqualTo: anchor, constant: -padding)
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    public func constrainMinBottom(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        respectSafeArea: Bool = true,
        toContentLayoutGuide: Bool = false
    ) -> Self {
        _ = self.constrainMinBottomValue(
            to: other,
            padding: padding,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        return self
    }

    public func constrainMaxBottomValue(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        respectSafeArea: Bool = true,
        toContentLayoutGuide: Bool = false
    ) -> NSLayoutConstraint {
        assert(!self.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let target = other ?? self.superview else {
            fatalError("No constraint target found")
        }
        let anchor: NSLayoutYAxisAnchor = if toContentLayoutGuide, let scrollView = target as? UIScrollView {
            scrollView.contentLayoutGuide.bottomAnchor
        } else {
            respectSafeArea ? target.safeAreaLayoutGuide.bottomAnchor : target.bottomAnchor
        }
        let constraint = self.bottomAnchor.constraint(lessThanOrEqualTo: anchor, constant: -padding)
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    public func constrainMaxBottom(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        respectSafeArea: Bool = true,
        toContentLayoutGuide: Bool = false
    ) -> Self {
        _ = self.constrainMaxBottomValue(
            to: other,
            padding: padding,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        return self
    }

    public func constrainMinHorizontalValue(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        respectSafeArea: Bool = true,
        toContentLayoutGuide: Bool = false
    ) -> (left: NSLayoutConstraint, right: NSLayoutConstraint) {
        let left = self.constrainMinLeftValue(
            to: other,
            padding: padding,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        let right = self.constrainMinRightValue(
            to: other,
            padding: padding,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        return (left: left, right: right)
    }

    @discardableResult
    public func constrainMinHorizontal(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        respectSafeArea: Bool = true,
        toContentLayoutGuide: Bool = false
    ) -> Self {
        _ = self.constrainMinHorizontalValue(
            to: other,
            padding: padding,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        return self
    }

    public func constrainMaxHorizontalValue(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        respectSafeArea: Bool = true,
        toContentLayoutGuide: Bool = false
    ) -> (left: NSLayoutConstraint, right: NSLayoutConstraint) {
        let left = self.constrainMaxLeftValue(
            to: other,
            padding: padding,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        let right = self.constrainMaxRightValue(
            to: other,
            padding: padding,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        return (left: left, right: right)
    }

    @discardableResult
    public func constrainMaxHorizontal(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        respectSafeArea: Bool = true,
        toContentLayoutGuide: Bool = false
    ) -> Self {
        _ = self.constrainMaxHorizontalValue(
            to: other,
            padding: padding,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        return self
    }

    public func constrainMinVerticalValue(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        respectSafeArea: Bool = true,
        toContentLayoutGuide: Bool = false
    ) -> (top: NSLayoutConstraint, bottom: NSLayoutConstraint) {
        let top = self.constrainMinTopValue(
            to: other,
            padding: padding,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        let bottom = self.constrainMinBottomValue(
            to: other,
            padding: padding,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        return (top: top, bottom: bottom)
    }

    @discardableResult
    public func constrainMinVertical(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        respectSafeArea: Bool = true,
        toContentLayoutGuide: Bool = false
    ) -> Self {
        _ = self.constrainMinVerticalValue(
            to: other,
            padding: padding,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        return self
    }

    public func constrainMaxVerticalValue(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        respectSafeArea: Bool = true,
        toContentLayoutGuide: Bool = false
    ) -> (top: NSLayoutConstraint, bottom: NSLayoutConstraint) {
        let top = self.constrainMaxTopValue(
            to: other,
            padding: padding,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        let bottom = self.constrainMaxBottomValue(
            to: other,
            padding: padding,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        return (top: top, bottom: bottom)
    }

    @discardableResult
    public func constrainMaxVertical(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        respectSafeArea: Bool = true,
        toContentLayoutGuide: Bool = false
    ) -> Self {
        _ = self.constrainMaxVerticalValue(
            to: other,
            padding: padding,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        return self
    }

    public func constrainMinAllSidesValue(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        respectSafeArea: Bool = true,
        toContentLayoutGuide: Bool = false
    ) -> (left: NSLayoutConstraint, right: NSLayoutConstraint, top: NSLayoutConstraint, bottom: NSLayoutConstraint) {
        let horizontal = self.constrainMinHorizontalValue(
            to: other,
            padding: padding,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        let vertical = self.constrainMinVerticalValue(
            to: other,
            padding: padding,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        return (left: horizontal.left, right: horizontal.right, top: vertical.top, bottom: vertical.bottom)
    }

    @discardableResult
    public func constrainMinAllSides(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        respectSafeArea: Bool = true,
        toContentLayoutGuide: Bool = false
    ) -> Self {
        _ = self.constrainMinAllSidesValue(
            to: other,
            padding: padding,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        return self
    }

    public func constrainMaxAllSidesValue(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        respectSafeArea: Bool = true,
        toContentLayoutGuide: Bool = false
    ) -> (left: NSLayoutConstraint, right: NSLayoutConstraint, top: NSLayoutConstraint, bottom: NSLayoutConstraint) {
        let horizontal = self.constrainMaxHorizontalValue(
            to: other,
            padding: padding,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        let vertical = self.constrainMaxVerticalValue(
            to: other,
            padding: padding,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        return (left: horizontal.left, right: horizontal.right, top: vertical.top, bottom: vertical.bottom)
    }

    @discardableResult
    public func constrainMaxAllSides(
        to other: UIView? = nil,
        padding: CGFloat = 0.0,
        respectSafeArea: Bool = true,
        toContentLayoutGuide: Bool = false
    ) -> Self {
        _ = self.constrainMaxAllSidesValue(
            to: other,
            padding: padding,
            respectSafeArea: respectSafeArea,
            toContentLayoutGuide: toContentLayoutGuide
        )
        return self
    }

    @discardableResult
    public func removeWidthConstraint() -> Self {
        for constraint in self.constraints {
            if constraint.firstAttribute == .width, constraint.firstItem as? UIView == self {
                // Remove any width constraints
                self.removeConstraint(constraint)
            }
        }
        return self
    }

    @discardableResult
    public func removeHeightConstraint() -> Self {
        for constraint in self.constraints {
            if constraint.firstAttribute == .height, constraint.firstItem as? UIView == self {
                // Remove any height constraints
                self.removeConstraint(constraint)
            }
        }
        return self
    }

    // MARK: - Background

    @discardableResult
    public func setBackgroundColor(to color: UIColor) -> Self {
        self.backgroundColor = color
        return self
    }

    @discardableResult
    public func setCornerRadius(to radius: Double, corners: CACornerMask? = nil) -> Self {
        self.layer.cornerRadius = radius
        if let corners {
            self.layer.maskedCorners = corners
        }
        return self
    }

    // MARK: - Border

    @discardableResult
    public func setBorder(width: CGFloat, color: UIColor?) -> Self {
        return self
            .setBorderWidth(to: width)
            .setBorderColor(to: color)
    }

    @discardableResult
    public func setBorderWidth(to width: CGFloat) -> Self {
        self.layer.borderWidth = width
        return self
    }

    @discardableResult
    public func setBorderColor(to color: UIColor?) -> Self {
        self.layer.borderColor = color?.cgColor
        return self
    }

    @discardableResult
    public func addBorder(width: CGFloat = 1.0, color: UIColor = UIColor.red) -> Self {
        return self.setBorder(width: width, color: color)
    }

    @discardableResult
    public func removeBorder() -> Self {
        return self.setBorder(width: 0, color: nil)
    }

    // MARK: - Shadow

    @discardableResult
    public func addShadow(
        color: UIColor = .black,
        opacity: Float = 0.1,
        offset: CGSize = CGSize(width: 0, height: 4),
        radius: CGFloat = 12
    ) -> Self {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offset
        self.layer.shadowRadius = radius
        return self
    }

    @discardableResult
    public func clearShadow() -> Self {
        self.layer.shadowColor = nil
        self.layer.shadowOpacity = 0.0
        self.layer.shadowOffset = CGSize()
        self.layer.shadowRadius = 0.0
        return self
    }

    // MARK: - Visibility

    @discardableResult
    public func setHidden(to isHidden: Bool) -> Self {
        self.isHidden = isHidden
        return self
    }

    @discardableResult
    public func setOpacity(to opacity: Double) -> Self {
        self.alpha = opacity
        return self
    }

    @discardableResult
    public func setLayerOpacity(to opacity: Double) -> Self {
        self.layer.opacity = Float(opacity)
        return self
    }

    @discardableResult
    public func setDisabledOpacity() -> Self {
        self.alpha = 0.4
        return self
    }

    @discardableResult
    public func setPressedOpacity() -> Self {
        self.alpha = 0.4
        return self
    }

    @discardableResult
    public func setInteractions(enabled: Bool) -> Self {
        self.isUserInteractionEnabled = enabled
        return self
    }

    // MARK: - Animations

    @discardableResult
    public func animateOpacityInteraction() -> Self {
        UIView.animate(
            withDuration: 0.1,
            delay: 0,
            options: [.curveEaseInOut, .allowUserInteraction],
            animations: {
                self.alpha = 0.25
            },
            completion: { _ in
                UIView.animate(
                    withDuration: 0.35,
                    delay: 0,
                    options: [.curveEaseInOut, .allowUserInteraction, .beginFromCurrentState],
                    animations: {
                        self.alpha = 1.0
                    },
                    completion: nil
                )
            }
        )
        return self
    }

    @discardableResult
    public func animatePressedOpacity() -> Self {
        self.alpha = 0.4
        return self
    }

    @discardableResult
    public func animateReleaseOpacity() -> Self {
        guard self.alpha.isLess(than: 1.0) else {
            // Don't animate release if we're already full opacity
            return self
        }
        // The following is thought out and not the result of a stroke
        // The reason we need two calls of UIView.animate is because UIScrollView has `delaysContentTouches` set to true
        // (This means that when you start a scroll gesture on a button/control, it won't consume the gesture and allow scrolling to occur)
        // (This also means animations get messed up)
        // First - if we just set the alpha without using UIView.animate with zero delay, it straight up won't work most of the time when
        // tapping quickly
        // Second - we can't just set it to 0.4 (what `animatePressedOpacity` sets it to), we have to set it lower, otherwise it won't
        // redraw the view and it will remain visually at 1.0 alpha
        UIView.animate(
            withDuration: 0.0,
            delay: 0,
            options: [.curveEaseInOut, .allowUserInteraction, .beginFromCurrentState],
            animations: {
                self.alpha = 0.39
            },
            completion: { _ in
                UIView.animate(
                    withDuration: 0.35,
                    delay: 0,
                    options: [.curveEaseInOut, .allowUserInteraction, .beginFromCurrentState],
                    animations: {
                        self.alpha = 1.0
                    },
                    completion: nil
                )
            }
        )
        return self
    }

    @discardableResult
    public func animateEntrance(duration: Double = 0.2, onCompletion: @escaping () -> Void = {}) -> Self {
        self.setOpacity(to: 0.0)
        self.transform = CGAffineTransform(translationX: 0, y: -10)
        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 2,
            options: [.curveEaseOut, .allowUserInteraction],
            animations: {
                self.setOpacity(to: 1.0)
                self.transform = CGAffineTransform(translationX: 0, y: 0)
            },
            completion: { _ in
                onCompletion()
            }
        )
        return self
    }

    @discardableResult
    public func animateExit(duration: Double = 0.2, onCompletion: @escaping () -> Void) -> Self {
        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 2,
            options: [.curveEaseOut, .allowUserInteraction],
            animations: {
                self.setOpacity(to: 0.0)
                self.transform = CGAffineTransform(translationX: 0, y: -10)
            },
            completion: { _ in
                onCompletion()
            }
        )
        return self
    }

    @discardableResult
    public func animateOpacity(to opacity: Double, duration: Double = 0.2, onCompletion: @escaping () -> Void = {}) -> Self {
        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 2,
            options: [.curveEaseOut, .allowUserInteraction],
            animations: {
                self.setOpacity(to: opacity)
            },
            completion: { _ in
                onCompletion()
            }
        )
        return self
    }

    // MARK: - Transformations

    @discardableResult
    public func setTransformation(to transformation: CGAffineTransform, animated: Bool = false) -> Self {
        if animated {
            UIView.animate(
                withDuration: 0.2,
                delay: 0,
                usingSpringWithDamping: 1.0,
                initialSpringVelocity: 2,
                options: [.curveEaseOut, .beginFromCurrentState, .allowUserInteraction],
                animations: {
                    self.transform = transformation
                }
            )
        } else {
            self.transform = transformation
        }
        return self
    }
}
