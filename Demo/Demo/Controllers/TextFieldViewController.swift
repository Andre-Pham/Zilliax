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
            .setOnBack({
                guard let nav = self.navigationController else {
                    assertionFailure("Expected navigation controller")
                    return
                }
                nav.popViewController(animated: true)
            })

        self.textField
            .constrainHorizontal(padding: Dimensions.screenContentPaddingHorizontal)
            .constrainCenterVertical()
            .setPlaceholder(to: "Placeholder")

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.onScreenTap))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
    }

    // MARK: Functions

    @objc
    private func onScreenTap(gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self.view)
        let hitView = self.view.hitTest(location, with: nil)
        if let hitView, hitView.existsWithinHierarchy(of: self.textField) {
            return
        }
        self.view.endEditing(true)
    }
}
