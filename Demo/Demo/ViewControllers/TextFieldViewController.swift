//
//  TextFieldViewController.swift
//  Demo
//

import UIKit

public class TextFieldViewController: UIViewController {
    // MARK: Properties

    private let header = HeaderView()
    private let textField = TextField()

    // MARK: Overridden Functions

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view
            .add(self.header)
            .add(self.textField)

        self.header
            .constrainTop()
            .constrainHorizontal(padding: Dimensions.screenContentPaddingHorizontal)
            .setTitle(to: "TextField")
            .setDescription(to: "A standard text field.")
            .setOnBack({ [weak self] in
                Navigation.pop(self)
            })

        self.textField
            .matchWidthConstrainCenter(padding: Dimensions.screenContentPaddingHorizontal, maxWidth: 400)
            .constrainCenterVertical()
            .setPlaceholder(to: "Placeholder")
            .setTapToDismiss(to: self.view)
    }
}
