//
//  SegmentedControlViewController.swift
//  Demo
//

import UIKit

public class SegmentedControlViewController: UIViewController {
    // MARK: Properties

    private let header = HeaderView()
    private let segmentedControl = SegmentedControl<Bool>()

    // MARK: Overridden Functions

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view
            .add(self.header)
            .add(self.segmentedControl)

        self.header
            .constrainTop()
            .constrainHorizontal(padding: Dimensions.screenContentPaddingHorizontal)
            .setTitle(to: "SegmentedControl")
            .setDescription(to: "A segmented control for selecting a single option.")
            .setOnBack({
                guard let nav = self.navigationController else {
                    assertionFailure("Expected navigation controller")
                    return
                }
                nav.popViewController(animated: true)
            })

        self.segmentedControl
            .constrainCenterVertical()
            .matchWidthConstrainCenter(padding: Dimensions.screenContentPaddingHorizontal, maxWidth: 400)
            .addSegment(value: true, label: "Correct", icon: .init(systemName: "checkmark"))
            .addSegment(value: false, label: "Wrong", icon: .init(systemName: "xmark"))
    }
}
