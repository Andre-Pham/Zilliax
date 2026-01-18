//
//  Scroll.swift
//  https://github.com/Andre-Pham/Zilliax
//
//  Created by Andre Pham.
//

import UIKit

public class Scroll: View {
    // MARK: Properties

    private let scrollView = UIScrollView()

    // MARK: Computed Properties

    public var viewCount: Int {
        return self.scrollView.subviews.count
    }

    // MARK: Overridden Functions

    public override func setup() {
        super.setup()

        self.add(self.scrollView)

        self.scrollView
            .useAutoLayout()
            .constrainAllSides(respectSafeArea: false)
    }

    // MARK: Functions

    @discardableResult
    public func append(_ view: UIView, animated: Bool = false) -> Self {
        if animated {
            view.setOpacity(to: 0.0)
            view.setHidden(to: true)
            self.scrollView.add(view)
            UIView.animate(
                withDuration: 0.2,
                delay: 0,
                usingSpringWithDamping: 1.0,
                initialSpringVelocity: 2,
                options: [.curveEaseOut],
                animations: {
                    view.setOpacity(to: 1.0)
                    view.setHidden(to: false)
                }
            )
        } else {
            self.scrollView.add(view)
        }
        return self
    }

    @discardableResult
    public func insert(_ view: UIView, at position: Int, animated: Bool = false) -> Self {
        let validatedPosition = min(position, self.viewCount)
        if animated {
            view.setOpacity(to: 0.0)
            view.setHidden(to: true)
            self.scrollView.insertSubview(view, at: validatedPosition)
            UIView.animate(
                withDuration: 0.2,
                delay: 0,
                usingSpringWithDamping: 1.0,
                initialSpringVelocity: 2,
                options: [.curveEaseOut],
                animations: {
                    view.setOpacity(to: 1.0)
                    view.setHidden(to: false)
                }
            )
        } else {
            self.scrollView.insertSubview(view, at: validatedPosition)
        }
        return self
    }

    @discardableResult
    public func appendGap(size: Double, animated: Bool = false) -> Self {
        let gapView = View().setHeightConstraint(to: size)
        return self.append(gapView, animated: animated)
    }

    @discardableResult
    public func insertGap(size: Double, at position: Int, animated: Bool = false) -> Self {
        let gapView = View().setHeightConstraint(to: size)
        return self.insert(gapView, at: position, animated: animated)
    }

    @discardableResult
    public func pop(_ view: UIView, animated: Bool = false) -> Self {
        if animated {
            UIView.animate(
                withDuration: 0.2,
                delay: 0,
                usingSpringWithDamping: 1.0,
                initialSpringVelocity: 2,
                options: [.curveEaseOut],
                animations: {
                    view.setOpacity(to: 0.0)
                    view.setHidden(to: true)
                },
                completion: { _ in
                    view.remove()
                    view.setOpacity(to: 1.0)
                    view.setHidden(to: false)
                }
            )
        } else {
            view.remove()
        }
        return self
    }

    @discardableResult
    public func pop(position: Int? = nil, animated: Bool = false) -> Self {
        let position = position ?? self.viewCount - 1
        guard position >= 0, self.viewCount > position else {
            return self
        }
        let view = self.scrollView.subviews[position]
        return self.pop(view, animated: animated)
    }

    @discardableResult
    public func setVerticalBounce(to state: Bool) -> Self {
        self.scrollView.alwaysBounceVertical = state
        return self
    }

    @discardableResult
    public func setHorizontalBounce(to state: Bool) -> Self {
        self.scrollView.alwaysBounceHorizontal = state
        return self
    }
    
    @discardableResult
    public func setDelaysContentTouches(to state: Bool) -> Self {
        self.scrollView.delaysContentTouches = state
        return self
    }

    @discardableResult
    public func scrollToBottom() -> Self {
        let bottomOffset = CGPoint(
            x: 0,
            y: self.scrollView.contentSize.height - self.scrollView.bounds.size.height + self.scrollView.contentInset.bottom
        )
        if bottomOffset.y > 0 {
            self.scrollView.setContentOffset(bottomOffset, animated: false)
        }
        return self
    }

    @discardableResult
    public func scrollToBottomAnimated(withEasing easingOption: UIView.AnimationOptions = .curveEaseInOut, duration: Double = 0.3) -> Self {
        let bottomOffset = CGPoint(
            x: 0,
            y: self.scrollView.contentSize.height - self.scrollView.bounds.size.height + self.scrollView.contentInset.bottom
        )
        if bottomOffset.y > 0 {
            UIView.animate(
                withDuration: duration,
                delay: 0,
                options: easingOption,
                animations: {
                    self.scrollView.contentOffset = bottomOffset
                },
                completion: nil
            )
        }
        return self
    }
}
