//
//  ControlViewController.swift
//  Demo
//

import UIKit

public class ControlViewController: UIViewController {
    // MARK: Properties

    private let header = HeaderView()
    private let control = Control()
    private let text = Text()

    // MARK: Overridden Functions

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view
            .add(self.header)
            .add(self.control)

        self.header
            .constrainTop()
            .constrainHorizontal(padding: Dimensions.screenContentPaddingHorizontal)
            .setTitle(to: "Control")
            .setDescription(to: "The base view for controls. Allows press and release interactions and animations.")
            .setOnBack({
                guard let nav = self.navigationController else {
                    assertionFailure("Expected navigation controller")
                    return
                }
                nav.popViewController(animated: true)
            })

        self.control
            .constrainCenter()
            .setWidthConstraint(to: 250)
            .setHeightConstraint(to: 200)
            .setBackgroundColor(to: Colors.fillSecondary)
            .add(self.text)
            .setOnPress({
                self.control.setTransformation(to: CGAffineTransform(scaleX: 0.8, y: 0.8), animated: true)
            })
            .setOnRelease({
                self.control.setTransformation(to: .identity, animated: true)
            })
            .setOnCancel({
                self.control.setTransformation(to: .identity, animated: true)
            })

        self.text
            .constrainCenter()
            .setText(to: "Hold Down")
            .setTextColor(to: Colors.textMuted)
    }
}
