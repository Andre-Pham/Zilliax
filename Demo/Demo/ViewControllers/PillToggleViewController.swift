//
//  PillToggleViewController.swift
//  Demo
//

import UIKit

public class PillToggleViewController: UIViewController {
    // MARK: Properties

    private let header = HeaderView()
    private let pillToggle = PillToggle()

    // MARK: Overridden Functions

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view
            .add(self.header)
            .add(self.pillToggle)

        self.header
            .constrainTop()
            .constrainHorizontal(padding: Dimensions.screenContentPaddingHorizontal)
            .setTitle(to: "PillToggle")
            .setDescription(to: "A pill that toggles on/off.")
            .setOnBack({
                guard let nav = self.navigationController else {
                    assertionFailure("Expected navigation controller")
                    return
                }
                nav.popViewController(animated: true)
            })

        self.pillToggle
            .constrainCenter()
            .setLabel(to: "Airplane Mode")
            .setIcon(to: .init(systemName: "airplane"))
    }
}
