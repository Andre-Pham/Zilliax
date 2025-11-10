//
//  PillButtonViewController.swift
//  Demo
//

import UIKit

public class PillButtonViewController: UIViewController {
    // MARK: Properties

    private let header = HeaderView()
    private let pillButton = PillButton()

    // MARK: Overridden Functions

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view
            .add(self.header)
            .add(self.pillButton)

        self.header
            .constrainTop()
            .constrainHorizontal(padding: Dimensions.screenContentPaddingHorizontal)
            .setTitle(to: "PillButton")
            .setDescription(to: "A standard pill-shaped button.")
            .setOnBack({
                guard let nav = self.navigationController else {
                    assertionFailure("Expected navigation controller")
                    return
                }
                nav.popViewController(animated: true)
            })

        self.pillButton
            .constrainCenter()
            .setLabel(to: "Pill Button")
            .setIcon(to: .init(systemName: "arrow.up", size: 16, weight: .bold))
    }
}
