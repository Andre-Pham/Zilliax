//
//  PillXViewController.swift
//  Demo
//

import UIKit

public class PillXViewController: UIViewController {
    // MARK: Properties

    private let header = HeaderView()
    private let pillX = PillX()

    // MARK: Overridden Functions

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view
            .add(self.header)
            .add(self.pillX)

        self.header
            .constrainTop()
            .constrainHorizontal(padding: Dimensions.screenContentPaddingHorizontal)
            .setTitle(to: "PillX")
            .setDescription(to: "A pill with a trailing x button.")
            .setOnBack({
                guard let nav = self.navigationController else {
                    assertionFailure("Expected navigation controller")
                    return
                }
                nav.popViewController(animated: true)
            })

        self.pillX
            .constrainCenter()
            .setLabel(to: "Photography")
            .setIcon(to: .init(systemName: "photo"))
    }
}
