//
//  SpinnerViewController.swift
//  Demo
//

import UIKit

public class SpinnerViewController: UIViewController {
    // MARK: Properties

    private let header = HeaderView()
    private let spinner = Spinner()

    // MARK: Overridden Functions

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view
            .add(self.header)
            .add(self.spinner)

        self.header
            .constrainTop()
            .constrainHorizontal(padding: Dimensions.screenContentPaddingHorizontal)
            .setTitle(to: "Spinner")
            .setDescription(to: "A loading spinner.")
            .setOnBack({
                guard let nav = self.navigationController else {
                    assertionFailure("Expected navigation controller")
                    return
                }
                nav.popViewController(animated: true)
            })

        self.spinner
            .constrainCenter()
    }
}
