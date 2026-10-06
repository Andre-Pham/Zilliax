//
//  NavBarViewController.swift
//  Demo
//

import UIKit

public class NavBarViewController: UIViewController {
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
            .setTitle(to: "NavBar")
            .setDescription(to: "A navigation bar with optional buttons.")
            .setOnBack({ [weak self] in
                Navigation.pop(self)
            })

        self.capsuleButton
            .constrainCenter()
            .setLabel(to: "Open Modal")
            .setOnTap({ [weak self] in
                Navigation.present(from: self, to: NavBarShowcaseViewController())
            })
    }
}

private class NavBarShowcaseViewController: UIViewController {
    // MARK: Properties

    private let navBar = NavBar()
    private let bodyText = Text()

    // MARK: Overridden Functions

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view
            .add(self.navBar)
            .add(self.bodyText)

        self.navBar
            .constrainTop()
            .constrainHorizontal()
            .setTitle(to: "NavBar Showcase")
            .addIconButton(alignment: .left, icon: .init(systemName: "xmark"), onTap: { [weak self] in
                Navigation.dismiss(self)
            })
            .addIconButton(alignment: .right, icon: .init(systemName: "arrow.up.arrow.down"))
            .configureIconButton(alignment: .right) { iconButton in
                iconButton?.setMenu(to: UIMenu(
                    title: "Sort By",
                    options: .singleSelection,
                    children: [
                        UIAction(title: "Name") { _ in },
                        UIAction(title: "Date Created", state: .on) { _ in },
                    ]
                ))
            }

        self.bodyText
            .constrainToUnderneath(of: self.navBar, padding: 10)
            .matchWidthConstrainCenter(padding: Dimensions.screenContentPaddingHorizontal, maxWidth: 400)
            .setTextColor(to: Colors.textMuted)
            .setFont(to: UIFont.systemFont(ofSize: 16, weight: .medium))
            .setText(
                to: "This is a model view controller which showcases a NavBar at the top, configured with left and right icon buttons."
            )
    }
}
