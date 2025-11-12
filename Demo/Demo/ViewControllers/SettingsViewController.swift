//
//  SettingsViewController.swift
//  Demo
//

import UIKit

public class SettingsViewController: UIViewController {
    // MARK: Properties

    private let placeholderText = Text()

    // MARK: Overridden Functions

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.placeholderText
            .addAsSubview(of: self.view)
            .constrainCenter()
            .setText(to: "Example Settings Tab")
    }
}
