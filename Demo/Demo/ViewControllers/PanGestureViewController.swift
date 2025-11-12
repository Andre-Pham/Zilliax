//
//  PanGestureViewController.swift
//  Demo
//

import UIKit

public class PanGestureViewController: UIViewController {
    // MARK: Properties

    private let header = HeaderView()
    private let panGesture = PanGesture()
    private let indicator = View()
    private let indicatorText = Text()

    private var indicatorCenterXConstraint: NSLayoutConstraint? = nil
    private var indicatorCenterYConstraint: NSLayoutConstraint? = nil

    // MARK: Overridden Functions

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view
            .add(self.header)
            .add(self.panGesture)

        self.header
            .constrainTop()
            .constrainHorizontal(padding: Dimensions.screenContentPaddingHorizontal)
            .setTitle(to: "PanGesture")
            .setDescription(to: "A base view for recognizing panning gestures.")
            .setOnBack({
                guard let nav = self.navigationController else {
                    assertionFailure("Expected navigation controller")
                    return
                }
                nav.popViewController(animated: true)
            })

        self.panGesture
            .constrainCenter()
            .setSizeConstraint(to: 250)
            .setCornerRadius(to: 16)
            .setBackgroundColor(to: Colors.fillSecondary)
            .add(self.indicator)
            .setOnGesture({ gesture in
                self.handlePan(gesture)
            })

        self.indicator
            .setSizeConstraint(to: 100)
            .setCornerRadius(to: 16)
            .setBackgroundColor(to: Colors.fillForeground)
            .add(self.indicatorText)

        let centerConstraints = self.indicator.constrainCenterValue(to: self.panGesture)
        self.indicatorCenterYConstraint = centerConstraints.vertical
        self.indicatorCenterXConstraint = centerConstraints.horizontal

        self.indicatorText
            .constrainCenter()
            .setText(to: "Drag Me")
            .setTextColor(to: Colors.textMuted)
    }

    // MARK: Functions

    private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.panGesture)
        self.updateIndicator(with: translation, state: gesture.state)
    }

    private func updateIndicator(with translation: CGPoint, state: UIGestureRecognizer.State) {
        self.view.layoutIfNeeded()

        let surfaceBounds = self.panGesture.bounds
        let indicatorBounds = self.indicator.bounds
        let maxOffsetX = max((surfaceBounds.width - indicatorBounds.width) / 2, 0)
        let maxOffsetY = max((surfaceBounds.height - indicatorBounds.height) / 2, 0)
        let clampedX = min(max(translation.x, -maxOffsetX), maxOffsetX)
        let clampedY = min(max(translation.y, -maxOffsetY), maxOffsetY)

        if state == .began {
            self.indicator.setTransformation(to: CGAffineTransform(scaleX: 0.8, y: 0.8), animated: true)
        }

        if state == .ended || state == .cancelled || state == .failed {
            self.indicatorCenterXConstraint?.constant = 0
            self.indicatorCenterYConstraint?.constant = 0
            UIView.animate(
                withDuration: 0.35,
                delay: 0.0,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0.4,
                options: [.allowUserInteraction, .curveEaseOut],
                animations: {
                    self.indicator.setTransformation(to: .identity)
                    self.view.layoutIfNeeded()
                }
            )
        } else {
            self.indicatorCenterXConstraint?.constant = clampedX
            self.indicatorCenterYConstraint?.constant = clampedY
            UIView.performWithoutAnimation({
                self.view.layoutIfNeeded()
            })
        }
    }
}
