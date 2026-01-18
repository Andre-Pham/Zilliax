//
//  PillViewController.swift
//  Demo
//

import UIKit

public class PillViewController: UIViewController {
    // MARK: Properties

    private let header = HeaderView()
    private let pill = Pill()

    // MARK: Overridden Functions

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view
            .add(self.header)
            .add(self.pill)

        self.header
            .constrainTop()
            .constrainHorizontal(padding: Dimensions.screenContentPaddingHorizontal)
            .setTitle(to: "Pill")
            .setDescription(to: "A pill-shaped badge.")
            .setOnBack({
                guard let nav = self.navigationController else {
                    assertionFailure("Expected navigation controller")
                    return
                }
                nav.popViewController(animated: true)
            })

        self.pill
            .constrainCenter()
            .setLabel(to: "Photography")
            .setIcon(to: .init(systemName: "photo"))
    }
}
