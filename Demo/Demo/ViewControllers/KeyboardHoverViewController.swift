//
//  KeyboardHoverViewController.swift
//  Demo
//

import UIKit

public class KeyboardHoverViewController: UIViewController {
    // MARK: Properties

    private let header = HeaderView()
    private let textField = ClearableTextField()
    private let keyboardHover = KeyboardHover()

    // MARK: Overridden Functions

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view
            .add(self.header)
            .add(self.textField)

        self.header
            .constrainTop()
            .constrainHorizontal(padding: Dimensions.screenContentPaddingHorizontal)
            .setTitle(to: "KeyboardHover")
            .setDescription(to: "Positions views relative to the keyboard layout guide (when active).")
            .setOnBack({ [weak self] in
                guard let nav = self?.navigationController else {
                    assertionFailure("Expected navigation controller")
                    return
                }
                nav.popViewController(animated: true)
            })

        self.keyboardHover
            .setView(to: self.textField)
            .configureBottomConstraint(padding: Dimensions.screenContentPaddingVertical)

        self.textField
            .matchWidthConstrainCenter(padding: Dimensions.screenContentPaddingHorizontal, maxWidth: 400)
            .setPlaceholder(to: "Placeholder")
            .setTapToDismiss(to: self.view)
    }
}
