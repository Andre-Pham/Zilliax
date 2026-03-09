//
//  TextButtonViewController.swift
//  Demo
//

import UIKit

public class TextButtonViewController: UIViewController {
    // MARK: Properties

    private let header = HeaderView()
    private let textButton = TextButton()

    // MARK: Overridden Functions

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view
            .add(self.header)
            .add(self.textButton)

        self.header
            .constrainTop()
            .constrainHorizontal(padding: Dimensions.screenContentPaddingHorizontal)
            .setTitle(to: "TextButton")
            .setDescription(to: "A text button.")
            .setOnBack({ [weak self] in
                guard let nav = self?.navigationController else {
                    assertionFailure("Expected navigation controller")
                    return
                }
                nav.popViewController(animated: true)
            })

        self.textButton
            .constrainCenter()
            .setLabel(to: "Text Button")
            .setIcon(to: .init(systemName: "arrow.up"))
    }
}
