//
//  ImageViewController.swift
//  Demo
//

import UIKit

public class ImageViewController: UIViewController {
    // MARK: Properties

    private let header = HeaderView()
    private let imageView = Image()

    // MARK: Overridden Functions

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view
            .add(self.header)
            .add(self.imageView)

        self.header
            .constrainTop()
            .constrainHorizontal(padding: Dimensions.screenContentPaddingHorizontal)
            .setTitle(to: "Image")
            .setDescription(to: "An image view.")
            .setOnBack({
                guard let nav = self.navigationController else {
                    assertionFailure("Expected navigation controller")
                    return
                }
                nav.popViewController(animated: true)
            })

        self.imageView
            .constrainCenter()
            .setWidthConstraint(to: 200)
            .setHeightConstraint(to: 200)
            .setCornerRadius(to: 16)
            .setClipsToBounds(to: true)
            .setImage(self.makeGradientImage(size: .init(width: 200, height: 200)))
    }

    // MARK: Functions

    private func makeGradientImage(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let cgContext = context.cgContext
            let colors = [
                UIColor.systemRed.cgColor,
                UIColor.systemBlue.cgColor,
            ] as CFArray
            let locations: [CGFloat] = [0.0, 1.0]
            guard let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors,
                locations: locations
            ) else {
                return
            }
            cgContext.drawLinearGradient(
                gradient,
                start: CGPoint(x: 0, y: 0),
                end: CGPoint(x: size.width, y: size.height),
                options: []
            )
        }
    }
}
