//
//  Toggle.swift
//  https://github.com/Andre-Pham/Zilliax
//
//  Created by Andre Pham.
//

import UIKit

class Toggle: View {
    // MARK: Static Properties

    private static let HEIGHT = 30.0
    private static let WIDTH = 60.0
    private static let INNER_PADDING = 5.0

    // MARK: Properties

    public private(set) var isOn = false

    private let overlay = View()
    private let thumb = View()
    private let control = Control()
    private var thumbLeftConstraint: NSLayoutConstraint? = nil
    private var onToggle: ((_ isOn: Bool) -> Void)? = nil

    // MARK: Overridden Functions

    public override func setup() {
        super.setup()

        self.setHeightConstraint(to: Self.HEIGHT)
            .setWidthConstraint(to: Self.WIDTH)
            .setCornerRadius(to: Self.HEIGHT / 2)
            .setBackgroundColor(to: Colors.fillSecondary)
            .add(self.overlay)
            .add(self.thumb)
            .add(self.control)

        self.overlay
            .constrainAllSides()
            .setBackgroundColor(to: Colors.black)
            .setOpacity(to: 0.05)
            .setCornerRadius(to: Self.HEIGHT / 2)

        self.thumb
            .setSizeConstraint(to: Self.HEIGHT - Self.INNER_PADDING * 2)
            .constrainCenterVertical()
            .setCornerRadius(to: (Self.HEIGHT - Self.INNER_PADDING * 2) / 2)
            .setBackgroundColor(to: Colors.fillForeground)

        self.thumbLeftConstraint = self.thumb.constrainLeftValue(padding: Self.INNER_PADDING)

        self.control
            .constrainAllSides(respectSafeArea: false)
            .setOnRelease({ [weak self] in
                self?.toggle()
            })

        self.updateAppearance(animated: false)
    }

    // MARK: Functions

    @discardableResult
    public func setState(isOn: Bool, animated: Bool = false, trigger: Bool = false) -> Self {
        guard self.isOn != isOn else {
            return self
        }
        self.isOn = isOn
        self.updateAppearance(animated: animated)
        if trigger {
            self.onToggle?(self.isOn)
        }
        return self
    }

    @discardableResult
    public func setOnToggle(_ callback: ((_ isOn: Bool) -> Void)?) -> Self {
        self.onToggle = callback
        return self
    }

    private func toggle() {
        self.isOn.toggle()
        self.updateAppearance(animated: true)
        self.onToggle?(self.isOn)
    }

    private func updateAppearance(animated: Bool) {
        let activeColor = self.isOn ? Colors.accent : Colors.fillSecondary
        self.thumbLeftConstraint?.constant = self.isOn
            ? Self.WIDTH - Self.INNER_PADDING - (Self.HEIGHT - Self.INNER_PADDING * 2)
            : Self.INNER_PADDING
        if animated {
            UIView.animate(
                withDuration: 0.2,
                delay: 0,
                options: [.curveEaseInOut, .allowUserInteraction, .beginFromCurrentState],
                animations: {
                    self.backgroundColor = activeColor
                    self.layoutIfNeeded()
                },
                completion: nil
            )
        } else {
            self.backgroundColor = activeColor
            self.layoutIfNeeded()
        }
    }
}
