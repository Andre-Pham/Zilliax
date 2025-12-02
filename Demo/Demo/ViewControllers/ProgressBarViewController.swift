//
//  ProgressBarViewController.swift
//  Demo
//

import UIKit

public class ProgressBarViewController: UIViewController {
    // MARK: Properties

    private let header = HeaderView()
    private let progressBar = ProgressBar()
    private var progressTimer: Timer? = nil
    private let progressValues: [Double] = [0.25, 0.5, 0.75, 1.0, 0.0]
    private var progressIndex = 0

    // MARK: Overridden Functions

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view
            .add(self.header)
            .add(self.progressBar)

        self.header
            .constrainTop()
            .constrainHorizontal(padding: Dimensions.screenContentPaddingHorizontal)
            .setTitle(to: "ProgressBar")
            .setDescription(to: "A progress bar.")
            .setOnBack({
                guard let nav = self.navigationController else {
                    assertionFailure("Expected navigation controller")
                    return
                }
                nav.popViewController(animated: true)
            })

        self.progressBar
            .constrainCenterVertical()
            .matchWidthConstrainCenter(padding: Dimensions.screenContentPaddingHorizontal, maxWidth: 400)
            .setProgress(to: 0.25)
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.startProgressTimer()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.progressTimer?.invalidate()
        self.progressTimer = nil
    }

    // MARK: Functions

    private func startProgressTimer() {
        guard self.progressTimer == nil else {
            return
        }
        self.progressTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else {
                return
            }
            self.progressIndex = (self.progressIndex + 1) % self.progressValues.count
            self.progressBar.setProgress(to: self.progressValues[self.progressIndex], animated: true)
        }
    }
}
