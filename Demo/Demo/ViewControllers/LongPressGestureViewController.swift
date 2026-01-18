//
//  LongPressGestureViewController.swift
//  Demo
//

import UIKit

public class LongPressGestureViewController: UIViewController {
    // MARK: Properties

    private let header = HeaderView()
    private let longPressGesture = LongPressGesture()
    private let text = Text()

    // MARK: Overridden Functions

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view
            .add(self.header)
            .add(self.longPressGesture)

        self.header
            .constrainTop()
            .constrainHorizontal(padding: Dimensions.screenContentPaddingHorizontal)
            .setTitle(to: "LongPressGesture")
            .setDescription(to: "A base view for recognizing long press gestures.")
            .setOnBack({
                guard let nav = self.navigationController else {
                    assertionFailure("Expected navigation controller")
                    return
                }
                nav.popViewController(animated: true)
            })

        self.longPressGesture
            .constrainCenter()
            .setWidthConstraint(to: 250)
            .setHeightConstraint(to: 200)
            .setBackgroundColor(to: Colors.fillSecondary)
            .add(self.text)
            .setOnGesture({ gesture in
                self.handleLongPress(gesture)
            })

        self.text
            .constrainCenter()
            .setText(to: "Long Press")
            .setTextColor(to: Colors.textMuted)
    }

    // MARK: Functions

    private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            self.longPressGesture.setTransformation(to: CGAffineTransform(scaleX: 0.8, y: 0.8), animated: true)
        }
        if gesture.state == .ended || gesture.state == .cancelled || gesture.state == .failed {
            self.longPressGesture.setTransformation(to: .identity, animated: true)
        }
    }
}
