//
//  IconViewController.swift
//  Demo
//

import UIKit

public class IconViewController: UIViewController {
    // MARK: Properties

    private let header = HeaderView()
    private let icon = Icon()

    // MARK: Overridden Functions

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view
            .add(self.header)
            .add(self.icon)

        self.header
            .constrainTop()
            .constrainHorizontal(padding: Dimensions.screenContentPaddingHorizontal)
            .setTitle(to: "Icon")
            .setDescription(to: "An icon view. By default, has no intrinsic width or height.")
            .setOnBack({
                guard let nav = self.navigationController else {
                    assertionFailure("Expected navigation controller")
                    return
                }
                nav.popViewController(animated: true)
            })

        self.icon
            .constrainCenter()
            .setIcon(to: .init(systemName: "arrow.up", size: 48, weight: .bold))
    }
}
