//
//  ClearableTextFieldViewController.swift
//  Demo
//

import UIKit

public class ClearableTextFieldViewController: UIViewController {
    // MARK: Properties

    private let header = HeaderView()
    private let clearableTextField = ClearableTextField()

    // MARK: Overridden Functions

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view
            .add(self.header)
            .add(self.clearableTextField)

        self.header
            .constrainTop()
            .constrainHorizontal(padding: Dimensions.screenContentPaddingHorizontal)
            .setTitle(to: "ClearableTextField")
            .setDescription(to: "A clearable text field.")
            .setOnBack({ [weak self] in
                Navigation.pop(self)
            })

        self.clearableTextField
            .matchWidthConstrainCenter(padding: Dimensions.screenContentPaddingHorizontal, maxWidth: 400)
            .constrainCenterVertical()
            .setPlaceholder(to: "Placeholder")
            .setTapToDismiss(to: self.view)
    }
}
