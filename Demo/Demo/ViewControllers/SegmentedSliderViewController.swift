//
//  SegmentedSliderViewController.swift
//  Demo
//

import UIKit

public class SegmentedSliderViewController: UIViewController {
    // MARK: Properties

    private let header = HeaderView()
    private let segmentedSlider = SegmentedSlider<Int>()

    // MARK: Overridden Functions

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view
            .add(self.header)
            .add(self.segmentedSlider)

        self.header
            .constrainTop()
            .constrainHorizontal(padding: Dimensions.screenContentPaddingHorizontal)
            .setTitle(to: "SegmentedSlider")
            .setDescription(to: "A segmented slider. Allows the selection of a discrete value.")
            .setOnBack({
                guard let nav = self.navigationController else {
                    assertionFailure("Expected navigation controller")
                    return
                }
                nav.popViewController(animated: true)
            })

        self.segmentedSlider
            .constrainCenterVertical()
            .constrainHorizontal(padding: Dimensions.screenContentPaddingHorizontal)
            .addSegment(value: 1, label: "One")
            .addSegment(value: 2, label: "Two")
            .addSegment(value: 3, label: "Three")
            .addSegment(value: 4, label: "Four")
    }
}
