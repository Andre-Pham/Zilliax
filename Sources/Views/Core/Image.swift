//
//  Image.swift
//  https://github.com/Andre-Pham/Zilliax
//
//  Created by Andre Pham.
//

import UIKit

public class Image: UIImageView {
    // MARK: Computed Properties

    public var imageSize: CGSize? {
        return self.image?.size
    }

    // MARK: Lifecycle

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }

    public convenience init() {
        self.init(frame: .zero)
    }

    // MARK: Functions

    public func setup() {
        self.useAutoLayout()
            .setContentMode(to: .scaleAspectFill)
    }

    @discardableResult
    public func setContentMode(to contentMode: UIView.ContentMode) -> Self {
        self.contentMode = contentMode
        return self
    }

    @discardableResult
    public func setImage(_ image: UIImage?) -> Self {
        self.image = image
        return self
    }

    @discardableResult
    public func setImage(_ image: CGImage?) -> Self {
        if let image {
            self.image = UIImage(cgImage: image)
        } else {
            self.image = nil
        }
        return self
    }

    @discardableResult
    public func resetImage() -> Self {
        self.image = nil
        return self
    }
}
