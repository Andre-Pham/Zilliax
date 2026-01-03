//
//  PillSelectViewController.swift
//  Demo
//

import UIKit

public class PillSelectViewController: UIViewController {
    // MARK: Properties

    private let header = HeaderView()
    private let pillSelect = PillSelect()

    // MARK: Overridden Functions

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view
            .add(self.header)
            .add(self.pillSelect)

        self.header
            .constrainTop()
            .constrainHorizontal(padding: Dimensions.screenContentPaddingHorizontal)
            .setTitle(to: "PillSelect")
            .setDescription(to: "A collection of pills for selecting a single option.")
            .setOnBack({
                guard let nav = self.navigationController else {
                    assertionFailure("Expected navigation controller")
                    return
                }
                nav.popViewController(animated: true)
            })

        self.pillSelect
            .constrainCenter()
    }
}
