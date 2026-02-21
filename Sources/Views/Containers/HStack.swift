//
//  HStack.swift
//  https://github.com/Andre-Pham/Zilliax
//
//  Created by Andre Pham.
//

import UIKit

public class HStack: View {
    // MARK: Properties

    private let stack = UIStackView()
    private var startSpacer: UIView? = nil
    private var endSpacer: UIView? = nil
    private var popping = Set<ObjectIdentifier>()

    // MARK: Computed Properties

    public var viewCount: Int {
        var result = self.stack.arrangedSubviews.count
        if self.hasStartSpacer {
            result -= 1
        }
        if self.hasEndSpacer {
            result -= 1
        }
        return result
    }

    public var hasStartSpacer: Bool {
        if let start = self.startSpacer, self.stack.arrangedSubviews.contains(start) {
            return true
        }
        return false
    }

    public var hasEndSpacer: Bool {
        if let end = self.endSpacer, self.stack.arrangedSubviews.contains(end) {
            return true
        }
        return false
    }

    private var horizontalSpacer: UIView {
        let spacerView = UIView()
        spacerView.useAutoLayout()
        spacerView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacerView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return spacerView
    }

    // MARK: Overridden Functions

    public override func setup() {
        super.setup()

        self.add(self.stack)

        self.stack
            .useAutoLayout()
            .constrainAllSides(respectSafeArea: false)

        self.stack.axis = .horizontal
        self.stack.alignment = .center
        self.stack.isLayoutMarginsRelativeArrangement = false
    }

    // MARK: Functions

    /// Add a permanent spacer to the start of the stack.
    /// The start spacer is not registered as one of the stack's views (excluded from indexing and view count).
    /// - Parameters:
    ///   - animated: True to animate adding the spacer
    /// - Returns: A reference to the view's instance
    @discardableResult
    public func addStartSpacer(animated: Bool = false, onCompletion: (() -> Void)? = nil) -> Self {
        guard !self.hasStartSpacer else {
            onCompletion?()
            return self
        }
        let spacer = self.horizontalSpacer
        self.startSpacer = spacer
        self.insert(spacer, at: 0, animated: animated, onCompletion: onCompletion)
        return self
    }

    /// Add a permanent spacer to the end of the stack.
    /// The end spacer is not registered as one of the stack's views (excluded from indexing and view count).
    /// - Parameters:
    ///   - animated: True to animate adding the spacer
    /// - Returns: A reference to the view's instance
    @discardableResult
    public func addEndSpacer(animated: Bool = false, onCompletion: (() -> Void)? = nil) -> Self {
        guard !self.hasEndSpacer else {
            onCompletion?()
            return self
        }
        let spacer = self.horizontalSpacer
        self.endSpacer = spacer
        self.append(spacer, animated: animated, onCompletion: onCompletion)
        return self
    }

    @discardableResult
    public func popStartSpacer(animated: Bool = false, onCompletion: (() -> Void)? = nil) -> Self {
        guard self.hasStartSpacer, let spacer = self.startSpacer else {
            onCompletion?()
            return self
        }
        self.pop(spacer, animated: animated, onCompletion: { [weak self] in
            self?.startSpacer = nil
            onCompletion?()
        })
        return self
    }

    @discardableResult
    public func popEndSpacer(animated: Bool = false, onCompletion: (() -> Void)? = nil) -> Self {
        guard self.hasEndSpacer, let spacer = self.endSpacer else {
            onCompletion?()
            return self
        }
        self.pop(spacer, animated: animated, onCompletion: { [weak self] in
            self?.endSpacer = nil
            onCompletion?()
        })
        return self
    }

    @discardableResult
    public func append(_ view: UIView, animated: Bool = false, onCompletion: (() -> Void)? = nil) -> Self {
        if animated {
            view.setOpacity(to: 0.0)
                .setHidden(to: true)
            if self.hasEndSpacer {
                self.stack.insertArrangedSubview(view, at: self.stack.arrangedSubviews.count - 1)
            } else {
                self.stack.addArrangedSubview(view)
            }
            UIView.animate(
                withDuration: 0.2,
                delay: 0.0,
                usingSpringWithDamping: 1.0,
                initialSpringVelocity: 2,
                options: [.curveEaseOut, .allowUserInteraction],
                animations: {
                    view.setHidden(to: false)
                        .setOpacity(to: 1.0)
                },
                completion: { _ in
                    onCompletion?()
                }
            )
        } else {
            if self.hasEndSpacer {
                self.stack.insertArrangedSubview(view, at: self.stack.arrangedSubviews.count - 1)
            } else {
                self.stack.addArrangedSubview(view)
            }
            onCompletion?()
        }
        return self
    }

    @discardableResult
    public func appendMany(_ views: [UIView], animated: Bool = false, onCompletion: (() -> Void)? = nil) -> Self {
        if animated {
            if views.isEmpty {
                onCompletion?()
                return self
            }
            for view in views {
                view.setOpacity(to: 0.0)
                    .setHidden(to: true)
                if self.hasEndSpacer {
                    self.stack.insertArrangedSubview(view, at: self.stack.arrangedSubviews.count - 1)
                } else {
                    self.stack.addArrangedSubview(view)
                }
            }
            for (index, view) in views.enumerated() {
                let delay = Double(index) * 0.05
                let isLast = index == views.count - 1
                UIView.animate(
                    withDuration: 0.2,
                    delay: delay,
                    usingSpringWithDamping: 1.0,
                    initialSpringVelocity: 2,
                    options: [.curveEaseOut, .allowUserInteraction],
                    animations: {
                        view.setHidden(to: false)
                            .setOpacity(to: 1.0)
                    },
                    completion: { _ in
                        if isLast {
                            onCompletion?()
                        }
                    }
                )
            }
        } else {
            for view in views {
                if self.hasEndSpacer {
                    self.stack.insertArrangedSubview(view, at: self.stack.arrangedSubviews.count - 1)
                } else {
                    self.stack.addArrangedSubview(view)
                }
            }
            onCompletion?()
        }
        return self
    }

    @discardableResult
    public func insert(_ view: UIView, at position: Int, animated: Bool = false, onCompletion: (() -> Void)? = nil) -> Self {
        let adjustedPosition = position + (self.hasStartSpacer ? 1 : 0)
        let minPosition = self.hasStartSpacer ? 1 : 0
        let maxPosition = self.hasEndSpacer ? self.stack.arrangedSubviews.count - 1 : self.stack.arrangedSubviews.count
        let validPosition = max(min(adjustedPosition, maxPosition), minPosition)
        if animated {
            view.setOpacity(to: 0.0)
                .setHidden(to: true)
            self.stack.insertArrangedSubview(view, at: validPosition)
            UIView.animate(
                withDuration: 0.2,
                delay: 0.0,
                usingSpringWithDamping: 1.0,
                initialSpringVelocity: 2,
                options: [.curveEaseOut, .allowUserInteraction],
                animations: {
                    view.setHidden(to: false)
                        .setOpacity(to: 1.0)
                },
                completion: { _ in
                    onCompletion?()
                }
            )
        } else {
            self.stack.insertArrangedSubview(view, at: validPosition)
            onCompletion?()
        }
        return self
    }

    @discardableResult
    public func appendSpacer(animated: Bool = false, onCompletion: (() -> Void)? = nil) -> Self {
        return self.append(self.horizontalSpacer, animated: animated, onCompletion: onCompletion)
    }

    @discardableResult
    public func insertSpacer(at position: Int, animated: Bool = false, onCompletion: (() -> Void)? = nil) -> Self {
        return self.insert(self.horizontalSpacer, at: position, animated: animated, onCompletion: onCompletion)
    }

    @discardableResult
    public func appendGap(size: Double, animated: Bool = false, onCompletion: (() -> Void)? = nil) -> Self {
        let gapView = View().setWidthConstraint(to: size)
        return self.append(gapView, animated: animated, onCompletion: onCompletion)
    }

    @discardableResult
    public func insertGap(size: Double, at position: Int, animated: Bool = false, onCompletion: (() -> Void)? = nil) -> Self {
        let gapView = View().setWidthConstraint(to: size)
        return self.insert(gapView, at: position, animated: animated, onCompletion: onCompletion)
    }

    @discardableResult
    public func pop(_ view: UIView, animated: Bool = false, onCompletion: (() -> Void)? = nil) -> Self {
        if animated {
            let id = ObjectIdentifier(view)
            guard self.stack.arrangedSubviews.contains(view), !self.popping.contains(id) else {
                onCompletion?()
                return self
            }
            self.popping.insert(id)
            UIView.animate(
                withDuration: 0.2,
                delay: 0,
                usingSpringWithDamping: 1.0,
                initialSpringVelocity: 2,
                options: [.curveEaseOut, .allowUserInteraction],
                animations: {
                    view.setOpacity(to: 0.0)
                        .setHidden(to: true)
                },
                completion: { _ in
                    self.popping.remove(id)
                    view.remove()
                        .setOpacity(to: 1.0)
                        .setHidden(to: false)
                    onCompletion?()
                }
            )
        } else {
            view.remove()
            onCompletion?()
        }
        return self
    }

    @discardableResult
    public func pop(position: Int? = nil, animated: Bool = false, onCompletion: (() -> Void)? = nil) -> Self {
        let viewCount = self.viewCount
        guard viewCount > 0 else {
            onCompletion?()
            return self
        }
        let lastPosition = viewCount - 1
        let targetPosition = position ?? lastPosition
        guard targetPosition >= 0, targetPosition <= lastPosition else {
            onCompletion?()
            return self
        }
        let adjustedPosition = targetPosition + (self.hasStartSpacer ? 1 : 0)
        let view = self.stack.arrangedSubviews[adjustedPosition]
        return self.pop(view, animated: animated, onCompletion: onCompletion)
    }

    @discardableResult
    public func setSpacing(to spacing: CGFloat) -> Self {
        self.stack.spacing = spacing
        return self
    }

    @discardableResult
    public func setCustomSpacing(after view: UIView, to spacing: CGFloat) -> Self {
        self.stack.setCustomSpacing(spacing, after: view)
        return self
    }

    @discardableResult
    public func setDistribution(to distribution: UIStackView.Distribution) -> Self {
        self.stack.distribution = distribution
        return self
    }

    @discardableResult
    public func setAlignment(to alignment: UIStackView.Alignment) -> Self {
        self.stack.alignment = alignment
        return self
    }
}
