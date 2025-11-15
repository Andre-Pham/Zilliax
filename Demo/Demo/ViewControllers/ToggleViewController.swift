//
//  ToggleViewController.swift
//  Demo
//

import UIKit

public class ToggleViewController: UIViewController {
    // MARK: Properties

    private let header = HeaderView()
    private let toggle = Toggle()

    // MARK: Overridden Functions

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view
            .add(self.header)
            .add(self.toggle)

        self.header
            .constrainTop()
            .constrainHorizontal(padding: Dimensions.screenContentPaddingHorizontal)
            .setTitle(to: "Toggle")
            .setDescription(to: "A control that toggles on/off.")
            .setOnBack({
                guard let nav = self.navigationController else {
                    assertionFailure("Expected navigation controller")
                    return
                }
                nav.popViewController(animated: true)
            })

        self.toggle
            .constrainCenter()
    }
}
