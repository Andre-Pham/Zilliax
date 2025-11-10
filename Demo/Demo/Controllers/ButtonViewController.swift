//
//  ButtonViewController.swift
//  Demo
//

import UIKit

public class ButtonViewController: UIViewController {
    // MARK: Properties

    private let header = HeaderView()
    private let button = Button()
    private let text = Text()
    private var count = 0

    // MARK: Overridden Functions

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view
            .add(self.header)
            .add(self.button)

        self.header
            .constrainTop()
            .constrainHorizontal(padding: Dimensions.screenContentPaddingHorizontal)
            .setTitle(to: "Button")
            .setDescription(
                to: "The base view for buttons. Allows tap interactions, press and release animations, and context menu triggers."
            )
            .setOnBack({
                guard let nav = self.navigationController else {
                    assertionFailure("Expected navigation controller")
                    return
                }
                nav.popViewController(animated: true)
            })

        self.button
            .constrainCenter()
            .setWidthConstraint(to: 250)
            .setHeightConstraint(to: 200)
            .setBackgroundColor(to: Colors.fillSecondary)
            .add(self.text)
            .animateOnPress(self.button)
            .setOnRelease({
                self.count += 1
                self.updateText()
            })

        self.text
            .constrainCenter()
            .setTextColor(to: Colors.textMuted)

        self.updateText()
    }

    // MARK: Functions

    private func updateText() {
        self.text.setText(to: "Tap Count: \(self.count)")
    }
}
