//
//  IconImageViewController.swift
//  Demo
//

import UIKit

public class IconImageViewController: UIViewController {
    // MARK: Properties

    private let header = HeaderView()
    private let iconImage = IconImage()

    // MARK: Overridden Functions

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view
            .add(self.header)
            .add(self.iconImage)

        self.header
            .constrainTop()
            .constrainHorizontal(padding: Dimensions.screenContentPaddingHorizontal)
            .setTitle(to: "IconImage")
            .setDescription(to: "An icon as an image view.")
            .setOnBack({
                guard let nav = self.navigationController else {
                    assertionFailure("Expected navigation controller")
                    return
                }
                nav.popViewController(animated: true)
            })

        self.iconImage
            .constrainCenter()
            .setIcon(to: .init(systemName: "arrow.up", size: 48, weight: .bold))
    }
}
