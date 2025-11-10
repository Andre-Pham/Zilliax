//
//  IconButtonViewController.swift
//  Demo
//

import UIKit

public class IconButtonViewController: UIViewController {
    // MARK: Properties

    private let header = HeaderView()
    private let iconButton = IconButton()

    // MARK: Overridden Functions

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view
            .add(self.header)
            .add(self.iconButton)

        self.header
            .constrainTop()
            .constrainHorizontal(padding: Dimensions.screenContentPaddingHorizontal)
            .setTitle(to: "IconButton")
            .setDescription(to: "A standard circular button with an icon.")
            .setOnBack({
                guard let nav = self.navigationController else {
                    assertionFailure("Expected navigation controller")
                    return
                }
                nav.popViewController(animated: true)
            })

        self.iconButton
            .constrainCenter()
            .setSizeConstraint(to: 44)
            .setIcon(to: .init(systemName: "arrow.up", size: 17, weight: .bold))
            .setBackgroundColor(to: Colors.fillSecondary)
    }
}
