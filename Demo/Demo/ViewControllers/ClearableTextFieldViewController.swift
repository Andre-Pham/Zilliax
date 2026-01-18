//
//  ClearableTextFieldViewController.swift
//  Demo
//

import UIKit

public class ClearableTextFieldViewController: UIViewController {
    // MARK: Properties

    private let header = HeaderView()
    private let clearableTextField = ClearableTextField()
    private let tapGesture = TapGesture()

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
            .setOnBack({
                guard let nav = self.navigationController else {
                    assertionFailure("Expected navigation controller")
                    return
                }
                nav.popViewController(animated: true)
            })

        self.clearableTextField
            .matchWidthConstrainCenter(padding: Dimensions.screenContentPaddingHorizontal, maxWidth: 400)
            .constrainCenterVertical()
            .setPlaceholder(to: "Placeholder")

        self.tapGesture
            .setCancelsTouchesInView(to: false)
            .setOnGesture({ gesture in
                let location = gesture.location(in: self.view)
                let hitView = self.view.hitTest(location, with: nil)
                if let hitView, hitView.existsWithinHierarchy(of: self.clearableTextField) {
                    return
                }
                self.view.endEditing(true)
            })
            .addGestureRecognizer(to: self.view)
    }
}
