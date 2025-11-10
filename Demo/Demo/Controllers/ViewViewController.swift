//
//  ViewViewController.swift
//  Demo
//

import UIKit

public class ViewViewController: UIViewController {
    // MARK: Properties

    private let header = HeaderView()
    private let demoView = View()
    private let tileTopLeft = View()
    private let tileBottomRight = View()

    // MARK: Overridden Functions

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view
            .add(self.header)
            .add(self.demoView)

        self.header
            .constrainTop()
            .constrainHorizontal(padding: Dimensions.screenContentPaddingHorizontal)
            .setTitle(to: "View")
            .setDescription(to: "The base view for all views.")
            .setOnBack({
                guard let nav = self.navigationController else {
                    assertionFailure("Expected navigation controller")
                    return
                }
                nav.popViewController(animated: true)
            })

        self.demoView
            .constrainCenter()
            .setSizeConstraint(to: 250)
            .setBackgroundColor(to: Colors.fillBackground)
            .add(self.tileTopLeft)
            .add(self.tileBottomRight)

        self.tileTopLeft
            .setSizeConstraint(proportion: 0.5)
            .constrainTop()
            .constrainLeft()
            .setBackgroundColor(to: Colors.black.withAlphaComponent(0.05))

        self.tileBottomRight
            .setSizeConstraint(proportion: 0.5)
            .constrainBottom()
            .constrainRight()
            .setBackgroundColor(to: Colors.black.withAlphaComponent(0.05))
    }
}
