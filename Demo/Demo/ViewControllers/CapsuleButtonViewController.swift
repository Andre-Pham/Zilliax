//
//  CapsuleButtonViewController.swift
//  Demo
//

import UIKit

public class CapsuleButtonViewController: UIViewController {
    // MARK: Properties

    private let header = HeaderView()
    private let capsuleButton = CapsuleButton()

    // MARK: Overridden Functions

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view
            .add(self.header)
            .add(self.capsuleButton)

        self.header
            .constrainTop()
            .constrainHorizontal(padding: Dimensions.screenContentPaddingHorizontal)
            .setTitle(to: "CapsuleButton")
            .setDescription(to: "A standard capsule-shaped button.")
            .setOnBack({ [weak self] in
                Navigation.pop(self)
            })

        self.capsuleButton
            .constrainCenter()
            .setLabel(to: "Capsule Button")
            .setIcon(to: .init(systemName: "arrow.up"))
    }
}
