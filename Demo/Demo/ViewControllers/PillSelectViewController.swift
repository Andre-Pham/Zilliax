//
//  PillSelectViewController.swift
//  Demo
//

import UIKit

public class PillSelectViewController: UIViewController {
    // MARK: Properties

    private let header = HeaderView()
    private let pillSelect = PillSelect<Int>()

    // MARK: Overridden Functions

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view
            .add(self.header)
            .add(self.pillSelect)

        self.header
            .constrainTop()
            .constrainHorizontal(padding: Dimensions.screenContentPaddingHorizontal)
            .setTitle(to: "PillSelect")
            .setDescription(to: "A collection of pills for selecting a single option.")
            .setOnBack({
                guard let nav = self.navigationController else {
                    assertionFailure("Expected navigation controller")
                    return
                }
                nav.popViewController(animated: true)
            })

        self.pillSelect
            .matchWidthConstrainCenter(padding: Dimensions.screenContentPaddingHorizontal, maxWidth: 400)
            .constrainCenterVertical()
            .setHorizontalAlignment(to: .center)
            .addSegment(value: 1, label: "Sun", icon: .init(systemName: "sun.max"))
            .addSegment(value: 2, label: "Moon", icon: .init(systemName: "moon.stars"))
            .addSegment(value: 3, label: "Cloud", icon: .init(systemName: "cloud"))
    }
}
