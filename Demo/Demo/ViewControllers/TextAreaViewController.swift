//
//  TextAreaViewController.swift
//  Demo
//

import UIKit

public class TextAreaViewController: UIViewController {
    // MARK: Properties

    private let header = HeaderView()
    private let textArea = TextArea()
    private let tapGesture = TapGesture()

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
            .setDescription(to: "A standard text area.")
            .setOnBack({ [weak self] in
                guard let nav = self?.navigationController else {
                    assertionFailure("Expected navigation controller")
                    return
                }
                nav.popViewController(animated: true)
            })

        self.textArea
            .matchWidthConstrainCenter(padding: Dimensions.screenContentPaddingHorizontal, maxWidth: 400)
            .constrainToUnderneath(of: self.header, padding: 36)
            .setHeightConstraint(proportion: 0.25)
            .setPlaceholder(to: "Placeholder")
            .setPlaceholderHiddenOnFocus(to: true)
            .setTextAlignment(to: .center)

        self.tapGesture
            .setCancelsTouchesInView(to: false)
            .setOnGesture({ [weak self] gesture in
                self?.handleTap(gesture)
            })
            .addGestureRecognizer(to: self.view)
    }

    // MARK: Functions

    private func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self.view)
        let hitView = self.view.hitTest(location, with: nil)
        if let hitView, hitView.existsWithinHierarchy(of: self.textArea) {
            return
        }
        self.view.endEditing(true)
    }
}
