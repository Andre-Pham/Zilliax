//
//  IconImage.swift
//  https://github.com/Andre-Pham/Zilliax
//
//  Created by Andre Pham.
//

import UIKit

public class IconImage: UIImageView {
    // MARK: Nested Types

    public typealias Config = Icon.Config

    // MARK: Properties

    public private(set) var config = Config(size: 26.0, color: Colors.black)

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
        self.setContentPriority(to: .required, for: .horizontal)
            .setContentPriority(to: .required, for: .vertical)
            .setIcon(to: self.config)
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
