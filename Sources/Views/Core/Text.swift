//
//  Text.swift
//  https://github.com/Andre-Pham/Zilliax
//
//  Created by Andre Pham.
//

import UIKit

public class Text: UILabel {
    // MARK: Lifecycle

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }

    // MARK: Functions

    public func setup() {
        self.useAutoLayout()
            .toggleWordWrapping(to: true)
            .setFont(to: UIFont.systemFont(ofSize: 18, weight: .medium))
            .setTextColor(to: Colors.textDark)
    }

    @discardableResult
    public func setText(to text: String?) -> Self {
        self.text = text
        return self
    }

    @discardableResult
    public func toggleWordWrapping(to status: Bool) -> Self {
        if status {
            self.numberOfLines = 0
            self.lineBreakMode = .byWordWrapping
        } else {
            // Defaults
            self.numberOfLines = 1
            self.lineBreakMode = .byTruncatingTail
        }
        return self
    }

    @discardableResult
    public func setFont(to font: UIFont?) -> Self {
        self.font = font
        return self
    }

    @discardableResult
    public func setSize(to size: CGFloat) -> Self {
        self.font = self.font.withSize(size)
        return self
    }

    @discardableResult
    public func setTextAlignment(to alignment: NSTextAlignment) -> Self {
        self.textAlignment = alignment
        return self
    }

    @discardableResult
    public func setTextColor(to color: UIColor) -> Self {
        self.textColor = color
        return self
    }

    @discardableResult
    public func setTextOpacity(to opacity: Double) -> Self {
        self.textColor = self.textColor.withAlphaComponent(opacity)
        return self
    }

    public func fits(text: String) -> Bool {
        self.layoutIfNeeded()
        let maxWidth = self.bounds.width
        let attributes: [NSAttributedString.Key: Any] = [.font: self.font as Any]
        let size = text.size(withAttributes: attributes)
        return size.width.isLessOrEqual(to: maxWidth)
    }
}
