//
//  HStackViewController.swift
//  Demo
//

import UIKit

public class HStackViewController: UIViewController {
    // MARK: Properties

    private let header = HeaderView()
    private let stack = HStack()

    // MARK: Computed Properties

    private var redSquare: View {
        return View()
            .setSizeConstraint(to: 50)
            .setBackgroundColor(to: .systemRed)
            .setCornerRadius(to: 4)
    }

    private var blueRectangle: View {
        return View()
            .setWidthConstraint(to: 70)
            .setHeightConstraint(to: 30)
            .setBackgroundColor(to: .systemBlue)
            .setCornerRadius(to: 4)
    }

    private var greenRectangle: View {
        return View()
            .setWidthConstraint(to: 30)
            .setHeightConstraint(to: 70)
            .setBackgroundColor(to: .systemGreen)
            .setCornerRadius(to: 4)
    }

    private var orangeCircle: View {
        return View()
            .setSizeConstraint(to: 40)
            .setCornerRadius(to: 20)
            .setBackgroundColor(to: .systemOrange)
    }

    // MARK: Overridden Functions

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view
            .add(self.header)
            .add(self.stack)

        self.header
            .constrainTop()
            .constrainHorizontal(padding: Dimensions.screenContentPaddingHorizontal)
            .setTitle(to: "HStack")
            .setDescription(to: "A container whereby subviews are arranged horizontally.")
            .setOnBack({
                guard let nav = self.navigationController else {
                    assertionFailure("Expected navigation controller")
                    return
                }
                nav.popViewController(animated: true)
            })

        self.stack
            .constrainCenter()
            .setSpacing(to: 8)
            .appendMany([
                self.redSquare,
                self.greenRectangle,
                self.blueRectangle,
                self.orangeCircle,
            ])
    }
}
