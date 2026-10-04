//
//  TextAreaViewController.swift
//  Demo
//

import UIKit

public class TextAreaViewController: UIViewController {
    // MARK: Properties

    private let header = HeaderView()
    private let textArea = TextArea()

    // MARK: Overridden Functions

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view
            .add(self.header)
            .add(self.textArea)

        self.header
            .constrainTop()
            .constrainHorizontal(padding: Dimensions.screenContentPaddingHorizontal)
            .setTitle(to: "TextArea")
            .setDescription(to: "An area for entering text.")
            .setOnBack({ [weak self] in
                Navigation.pop(self)
            })

        self.textArea
            .matchWidthConstrainCenter(padding: Dimensions.screenContentPaddingHorizontal, maxWidth: 400)
            .constrainToUnderneath(of: self.header, padding: 36)
            .setHeightConstraint(proportion: 0.25)
            .setPlaceholder(to: "Placeholder")
            .setPlaceholderHiddenOnFocus(to: true)
            .setTextAlignment(to: .center)
            .setTapToDismiss(to: self.view)
    }
}
