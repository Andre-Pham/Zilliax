//
//  Button.swift
//  https://github.com/Andre-Pham/Zilliax
//
//  Created by Andre Pham.
//

import UIKit

public class Button: UIButton {
    // MARK: Properties

    private var onPress: (() -> Void)? = nil
    private var onRelease: (() -> Void)? = nil
    private var onCancel: (() -> Void)? = nil
    private var onMenuOpen: (() -> Void)? = nil
    private var onMenuClose: (() -> Void)? = nil
    private var animateMenuOpen: (() -> Void)? = nil
    private var animateMenuClose: (() -> Void)? = nil
    private var animatedOnPress: UIView? = nil

    // MARK: Computed Properties

    public var isDisabled: Bool {
        return !self.isEnabled
    }

    // MARK: Lifecycle

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }

    // MARK: Overridden Functions

    public override func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        willDisplayMenuFor configuration: UIContextMenuConfiguration,
        animator: UIContextMenuInteractionAnimating?
    ) {
        animator?.addAnimations {
            self.animateMenuOpen?()
        }
        animator?.addCompletion {
            self.onMenuOpen?()
        }
    }

    public override func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        willEndFor configuration: UIContextMenuConfiguration,
        animator: (any UIContextMenuInteractionAnimating)?
    ) {
        animator?.addAnimations {
            self.animateMenuClose?()
        }
        animator?.addCompletion {
            self.onMenuClose?()
        }
    }

    // MARK: Functions

    public func setup() {
        self.useAutoLayout()
        self.addTarget(self, action: #selector(self.onPressCallback), for: .touchDown)
        self.addTarget(self, action: #selector(self.onReleaseCallback), for: [.touchUpInside, .touchUpOutside])
        self.addTarget(self, action: #selector(self.onCancelCallback), for: .touchCancel)
    }

    @discardableResult
    public func setOnPress(_ callback: (() -> Void)?) -> Self {
        self.onPress = callback
        return self
    }

    @discardableResult
    public func setOnRelease(_ callback: (() -> Void)?) -> Self {
        self.onRelease = callback
        return self
    }

    @discardableResult
    public func setOnCancel(_ callback: (() -> Void)?) -> Self {
        self.onCancel = callback
        return self
    }

    @discardableResult
    public func animateOnPress(_ target: UIView?) -> Self {
        self.animatedOnPress = target
        return self
    }

    @discardableResult
    public func setDisabled(to state: Bool) -> Self {
        self.isEnabled = !state
        return self
    }

    @discardableResult
    public func setMenu(to menu: UIMenu?) -> Self {
        self.menu = menu
        self.showsMenuAsPrimaryAction = menu != nil
        let interaction = UIContextMenuInteraction(delegate: self)
        self.addInteraction(interaction)
        return self
    }

    @discardableResult
    public func setMenuCallbacks(onOpen: (() -> Void)? = nil, onClose: (() -> Void)? = nil) -> Self {
        self.onMenuOpen = onOpen
        self.onMenuClose = onClose
        return self
    }

    @discardableResult
    public func setMenuAnimations(onOpen: (() -> Void)? = nil, onClose: (() -> Void)? = nil) -> Self {
        self.animateMenuOpen = onOpen
        self.animateMenuClose = onClose
        return self
    }

    @discardableResult
    public func removeMenu() -> Self {
        self.setMenu(to: nil)
            .setMenuCallbacks()
            .setMenuAnimations()
        return self
    }

    @objc
    private func onPressCallback() {
        self.animatedOnPress?.animatePressedOpacity()
        self.onPress?()
    }

    @objc
    private func onReleaseCallback() {
        self.onRelease?()
        if !self.isDisabled {
            // Only animate opacity if button didn't become disabled
            self.animatedOnPress?.animateReleaseOpacity()
        }
    }

    @objc
    private func onCancelCallback() {
        self.onCancel?()
        if !self.isDisabled {
            // Only animate opacity if button didn't become disabled
            self.animatedOnPress?.animateReleaseOpacity()
        }
    }
}
