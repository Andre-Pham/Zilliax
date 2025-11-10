//
//  IconImage.swift
//  https://github.com/Andre-Pham/Zilliax
//
//  Created by Andre Pham.
//

import UIKit

public class IconImage: UIImageView {
    // MARK: Nested Types

    public struct Config {
        // MARK: Properties

        public let image: UIImage?
        public let systemName: String?
        public let weight: UIImage.SymbolWeight?
        public let color: UIColor?
        public let size: Double?

        // MARK: Lifecycle

        public init(
            image: UIImage? = nil,
            size: Double? = nil
        ) {
            self.image = image
            self.systemName = nil
            self.size = size
            self.weight = nil
            self.color = nil
        }

        public init(
            systemName: String? = nil,
            size: Double? = nil,
            weight: UIImage.SymbolWeight? = nil,
            color: UIColor? = nil
        ) {
            self.image = nil
            self.systemName = systemName
            self.size = size
            self.weight = weight
            self.color = color
        }

        private init(
            image: UIImage?,
            systemName: String?,
            size: Double?,
            weight: UIImage.SymbolWeight?,
            color: UIColor?
        ) {
            self.image = image
            self.systemName = systemName
            self.size = size
            self.weight = weight
            self.color = color
        }

        // MARK: Functions

        @discardableResult
        public func merge(_ config: Self) -> Self {
            return Self(
                image: config.systemName == nil ? (config.image ?? self.image) : nil,
                systemName: config.image == nil ? (config.systemName ?? self.systemName) : nil,
                size: config.size ?? self.size,
                weight: config.weight ?? self.weight,
                color: config.color ?? self.color
            )
        }

        public func with(
            image: UIImage? = nil,
            size: Double? = nil
        ) -> Self {
            return Self(
                image: image ?? self.image,
                systemName: image == nil ? self.systemName : nil,
                size: size ?? self.size,
                weight: self.weight,
                color: self.color
            )
        }

        public func with(
            systemName: String? = nil,
            size: Double? = nil,
            weight: UIImage.SymbolWeight? = nil,
            color: UIColor? = nil
        ) -> Self {
            return Self(
                image: systemName == nil ? self.image : nil,
                systemName: systemName ?? self.systemName,
                size: size ?? self.size,
                weight: weight ?? self.weight,
                color: color ?? self.color
            )
        }
    }

    // MARK: Properties

    private var config = Config(size: 24.0, color: Colors.black)

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
        self.contentMode = .scaleAspectFit
        self.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.setContentCompressionResistancePriority(.required, for: .vertical)
        self.setIcon(to: self.config)
    }

    @discardableResult
    public func setIcon(to config: Config) -> Self {
        if let weight = config.weight {
            self.setWeight(to: weight)
        }
        if let size = config.size {
            self.setSize(to: size)
        }
        if let color = config.color {
            self.setColor(to: color)
        }
        if let image = config.image {
            self.setImage(to: image)
        } else if let systemName = config.systemName {
            self.setSymbol(systemName: systemName)
        }
        return self
    }

    @discardableResult
    public func setImage(to image: UIImage) -> Self {
        self.config = self.config.with(image: image)
        self.image = image
        return self
    }

    @discardableResult
    public func setSymbol(systemName: String) -> Self {
        if self.config.size != nil, self.config.image != nil {
            self.removeWidthConstraint()
                .removeHeightConstraint()
        }
        self.config = self.config.with(systemName: systemName)
        let systemImage = UIImage(systemName: systemName)
        if systemImage == nil {
            assertionFailure("Could not find system icon with name \(systemName)")
        }
        let image = systemImage ?? UIImage(systemName: "questionmark.circle.fill")!
        if let size = self.config.size {
            if let weight = self.config.weight {
                let config = UIImage.SymbolConfiguration(pointSize: size, weight: weight)
                self.image = image.withConfiguration(config)
            } else {
                let config = UIImage.SymbolConfiguration(pointSize: size)
                self.image = image.withConfiguration(config)
            }
        } else if let weight = self.config.weight {
            let config = UIImage.SymbolConfiguration(weight: weight)
            self.image = image.withConfiguration(config)
        } else {
            self.image = image
        }
        return self
    }

    @discardableResult
    public func setSize(to size: Double) -> Self {
        if self.config.size != nil, self.config.image != nil {
            self.removeWidthConstraint()
                .removeHeightConstraint()
        }
        self.config = self.config.with(size: size)
        if self.config.image != nil {
            self.setWidthConstraint(to: size)
                .setHeightConstraint(to: size)
        } else if let systemName = self.config.systemName {
            let systemImage = UIImage(systemName: systemName)
            if systemImage == nil {
                assertionFailure("Could not find system icon with name \(systemName)")
            }
            let image = systemImage ?? UIImage(systemName: "questionmark.circle.fill")!
            if let weight = self.config.weight {
                let config = UIImage.SymbolConfiguration(pointSize: size, weight: weight)
                self.image = image.withConfiguration(config)
            } else {
                let config = UIImage.SymbolConfiguration(pointSize: size)
                self.image = image.withConfiguration(config)
            }
        }
        return self
    }

    @discardableResult
    public func setWeight(to weight: UIImage.SymbolWeight) -> Self {
        self.config = self.config.with(weight: weight)
        if let systemName = self.config.systemName {
            let systemImage = UIImage(systemName: systemName)
            if systemImage == nil {
                assertionFailure("Could not find system icon with name \(systemName)")
            }
            let image = systemImage ?? UIImage(systemName: "questionmark.circle.fill")!
            if let size = self.config.size {
                let config = UIImage.SymbolConfiguration(pointSize: size, weight: weight)
                self.image = image.withConfiguration(config)
            } else {
                let config = UIImage.SymbolConfiguration(weight: weight)
                self.image = image.withConfiguration(config)
            }
        }
        return self
    }

    @discardableResult
    public func setColor(to color: UIColor) -> Self {
        self.config = self.config.with(color: color)
        self.tintColor = color
        return self
    }
}
