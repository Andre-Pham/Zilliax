//
//  IconSpinnerViewController.swift
//  Demo
//

import UIKit

public class IconSpinnerViewController: UIViewController {
    // MARK: Properties

    private let header = HeaderView()
    private let spinner = IconSpinner()

    // MARK: Overridden Functions

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view
            .add(self.header)
            .add(self.spinner)

        self.header
            .constrainTop()
            .constrainHorizontal(padding: Dimensions.screenContentPaddingHorizontal)
            .setTitle(to: "IconSpinner")
            .setDescription(to: "An icon spinner.")
            .setOnBack({ [weak self] in
                guard let nav = self?.navigationController else {
                    assertionFailure("Expected navigation controller")
                    return
                }
                nav.popViewController(animated: true)
            })

        self.spinner
            .constrainCenter()
    }
}
