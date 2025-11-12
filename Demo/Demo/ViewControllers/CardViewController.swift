//
//  CardViewController.swift
//  Demo
//

import UIKit

public class CardViewController: UIViewController {
    // MARK: Properties

    private let header = HeaderView()
    private let card = Card()
    private let text = Text()

    // MARK: Overridden Functions

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view
            .add(self.header)
            .add(self.card)

        self.header
            .constrainTop()
            .constrainHorizontal(padding: Dimensions.screenContentPaddingHorizontal)
            .setTitle(to: "Card")
            .setDescription(to: "A standard card view.")
            .setOnBack({
                guard let nav = self.navigationController else {
                    assertionFailure("Expected navigation controller")
                    return
                }
                nav.popViewController(animated: true)
            })

        self.card
            .constrainCenter()
            .setWidthConstraint(to: 250)
            .setHeightConstraint(to: 200)
            .add(self.text)

        self.text
            .constrainCenter()
            .setText(to: "Card")
            .setTextColor(to: Colors.textMuted)
    }
}
