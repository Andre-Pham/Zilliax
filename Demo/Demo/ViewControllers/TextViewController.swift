//
//  TextViewController.swift
//  Demo
//

import UIKit

public class TextViewController: UIViewController {
    // MARK: Properties

    private let header = HeaderView()
    private let text = Text()

    // MARK: Overridden Functions

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view
            .add(self.header)
            .add(self.text)

        self.header
            .constrainTop()
            .constrainHorizontal(padding: Dimensions.screenContentPaddingHorizontal)
            .setTitle(to: "Text")
            .setDescription(to: "A standard text view.")
            .setOnBack({
                guard let nav = self.navigationController else {
                    assertionFailure("Expected navigation controller")
                    return
                }
                nav.popViewController(animated: true)
            })

        self.text
            .constrainCenter()
            .setText(to: "Hello World")
            .setSize(to: 24)
    }
}
