//
//  StepperViewController.swift
//  Demo
//

import UIKit

public class StepperViewController: UIViewController {
    // MARK: Properties

    private let header = HeaderView()
    private let stepper = Stepper()

    // MARK: Overridden Functions

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view
            .add(self.header)
            .add(self.stepper)

        self.header
            .constrainTop()
            .constrainHorizontal(padding: Dimensions.screenContentPaddingHorizontal)
            .setTitle(to: "Stepper")
            .setDescription(to: "A control that increments/decrements a number.")
            .setOnBack({
                guard let nav = self.navigationController else {
                    assertionFailure("Expected navigation controller")
                    return
                }
                nav.popViewController(animated: true)
            })

        self.stepper
            .constrainCenter()
    }
}
