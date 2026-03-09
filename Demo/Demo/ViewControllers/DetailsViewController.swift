//
//  DetailsViewController.swift
//  Demo
//

import UIKit

public class DetailsViewController: UIViewController {
    // MARK: Properties

    private let header = HeaderView()
    private let card = Card()
    private let details = Details()

    // MARK: Overridden Functions

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view
            .add(self.header)
            .add(self.card)

        self.header
            .constrainTop()
            .constrainHorizontal(padding: Dimensions.screenContentPaddingHorizontal)
            .setTitle(to: "Details")
            .setDescription(to: "A stacked list of title-value rows for compact detail summaries.")
            .setOnBack({ [weak self] in
                guard let nav = self?.navigationController else {
                    assertionFailure("Expected navigation controller")
                    return
                }
                nav.popViewController(animated: true)
            })

        self.card
            .matchWidthConstrainCenter(padding: Dimensions.screenContentPaddingHorizontal, maxWidth: 400)
            .constrainCenterVertical()
            .add(self.details)

        self.details
            .constrainAllSides(padding: 20, respectSafeArea: false)
            .addRow(title: "Order", value: "#4812")
            .addRow(title: "Status", value: "Processing")
            .addRow(title: "Placed", value: "Mar 9, 2026")
            .addDivider()
            .addRow(title: "Total", value: "$128.00")
    }
}
