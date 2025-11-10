//
//  SliderViewController.swift
//  Demo
//

import UIKit

public class SliderViewController: UIViewController {
    // MARK: Properties

    private let header = HeaderView()
    private let slider = Slider()

    // MARK: Overridden Functions

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view
            .add(self.header)
            .add(self.slider)

        self.header
            .constrainTop()
            .constrainHorizontal(padding: Dimensions.screenContentPaddingHorizontal)
            .setTitle(to: "Slider")
            .setDescription(to: "A continuous slider. Allows the selection of a value within a given range.")
            .setOnBack({
                guard let nav = self.navigationController else {
                    assertionFailure("Expected navigation controller")
                    return
                }
                nav.popViewController(animated: true)
            })

        self.slider
            .constrainCenterVertical()
            .constrainHorizontal(padding: Dimensions.screenContentPaddingHorizontal)
    }
}
