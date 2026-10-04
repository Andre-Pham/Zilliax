//
//  TabBarButtonViewController.swift
//  Demo
//

import UIKit

public class TabBarButtonViewController: UIViewController {
    // MARK: Properties

    private let header = HeaderView()
    private let tabBarButton = TabBarButton()

    // MARK: Overridden Functions

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view
            .add(self.header)
            .add(self.tabBarButton)

        self.header
            .constrainTop()
            .constrainHorizontal(padding: Dimensions.screenContentPaddingHorizontal)
            .setTitle(to: "TabBarButton")
            .setDescription(to: "Used with TabBarController to create a responsive tab bar.")
            .setOnBack({ [weak self] in
                Navigation.pop(self)
            })

        self.tabBarButton
            .constrainHorizontal()
            .constrainCenterVertical()
            .setHeightConstraint(to: 68)
            .setColor(to: Colors.fillBackground)
            .setLabel(to: "Home")
            .setIcon(to: .init(systemName: "house.fill"))
    }
}
