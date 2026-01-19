//
//  TapGestureViewController.swift
//  Demo
//

import UIKit

public class TapGestureViewController: UIViewController {
    // MARK: Properties

    private let header = HeaderView()
    private let tapGesture = TapGesture()
    private let text = Text()
    private var tapCount = 0

    // MARK: Overridden Functions

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view
            .add(self.header)
            .add(self.tapGesture)

        self.header
            .constrainTop()
            .constrainHorizontal(padding: Dimensions.screenContentPaddingHorizontal)
            .setTitle(to: "TapGesture")
            .setDescription(to: "A base view for recognizing tap gestures.")
            .setOnBack({
                guard let nav = self.navigationController else {
                    assertionFailure("Expected navigation controller")
                    return
                }
                nav.popViewController(animated: true)
            })

        self.tapGesture
            .constrainCenter()
            .setWidthConstraint(to: 250)
            .setHeightConstraint(to: 200)
            .setBackgroundColor(to: Colors.fillSecondary)
            .add(self.text)
            .setOnGesture({ [weak self] gesture in
                self?.handleTap(gesture)
            })

        self.text
            .constrainCenter()
            .setTextColor(to: Colors.textMuted)
            .setText(to: "Tap count: 0")
    }

    // MARK: Functions

    private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard gesture.state == .ended else {
            return
        }
        self.tapCount += 1
        self.text.setText(to: "Tap count: \(self.tapCount)")
    }
}
