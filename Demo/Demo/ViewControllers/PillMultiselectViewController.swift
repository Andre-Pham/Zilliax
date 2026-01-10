//
//  PillMultiselectViewController.swift
//  Demo
//

import UIKit

public class PillMultiselectViewController: UIViewController {
    // MARK: Properties

    private let header = HeaderView()
    private let pillMultiselect = PillMultiselect<Int>()

    // MARK: Overridden Functions

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view
            .add(self.header)
            .add(self.pillMultiselect)

        self.header
            .constrainTop()
            .constrainHorizontal(padding: Dimensions.screenContentPaddingHorizontal)
            .setTitle(to: "PillMultiselect")
            .setDescription(to: "A collection of pills for selecting multiple options.")
            .setOnBack({
                guard let nav = self.navigationController else {
                    assertionFailure("Expected navigation controller")
                    return
                }
                nav.popViewController(animated: true)
            })

        self.pillMultiselect
            .matchWidthConstrainCenter(padding: Dimensions.screenContentPaddingHorizontal, maxWidth: 400)
            .constrainCenterVertical()
            .setHorizontalAlignment(to: .center)
            .addSegment(value: 1, label: "Sun", icon: .init(systemName: "sun.max"))
            .addSegment(value: 2, label: "Moon", icon: .init(systemName: "moon.stars"))
            .addSegment(value: 3, label: "Cloud", icon: .init(systemName: "cloud"))
    }
}
