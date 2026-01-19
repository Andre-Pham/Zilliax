//
//  ScrollViewController.swift
//  Demo
//

import UIKit

public class ScrollViewController: UIViewController {
    // MARK: Properties

    private let header = HeaderView()
    private let scroll = Scroll()
    private let stack = VStack()

    // MARK: Overridden Functions

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view
            .add(self.header)
            .add(self.scroll)

        self.header
            .constrainTop()
            .constrainHorizontal(padding: Dimensions.screenContentPaddingHorizontal)
            .setTitle(to: "Scroll")
            .setDescription(to: "A container that scrolls.")
            .setOnBack({
                guard let nav = self.navigationController else {
                    assertionFailure("Expected navigation controller")
                    return
                }
                nav.popViewController(animated: true)
            })

        self.scroll
            .constrainHorizontal(respectSafeArea: false)
            .constrainToUnderneath(of: self.header, padding: 24)
            .constrainBottom()
            .setVerticalBounce(to: true)
            .append(self.stack)

        self.stack
            .constrainTop(toContentLayoutGuide: true)
            .constrainBottom(padding: Dimensions.screenContentPaddingVertical, toContentLayoutGuide: true)
            .constrainHorizontal(padding: Dimensions.screenContentPaddingHorizontal)
            .setSpacing(to: 12)

        for index in 1...12 {
            let card = Card()
                .setHeightConstraint(to: 50)

            Text()
                .addAsSubview(of: card)
                .constrainCenter()
                .setText(to: "Row \(index)")
                .setTextColor(to: Colors.textMuted)

            self.stack.append(card)

            card.constrainHorizontal()
        }
    }
}
