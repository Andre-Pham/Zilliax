//
//  TextArea.swift
//  https://github.com/Andre-Pham/Zilliax
//
//  Created by Andre Pham.
//

import UIKit

public class TextArea: View, UITextViewDelegate {
    // MARK: Properties

    private let textView = InternalTextView()
    private let placeholderText = Text()
    private var onSubmit: ((String) -> Void)? = nil
    private var onFocus: (() -> Void)? = nil
    private var onUnfocus: (() -> Void)? = nil
    private var onChange: ((String) -> Void)? = nil

    // MARK: Computed Properties

    public var text: String {
        return self.textView.text ?? ""
    }

    // MARK: Overridden Functions

    public override func setup() {
        super.setup()

        self.add(self.textView)

        self.textView
            .useAutoLayout()
            .constrainAllSides(respectSafeArea: false)

        self.textView.delegate = self
        self.textView.backgroundColor = .clear
        self.textView.isScrollEnabled = true
        self.textView.textContainer.maximumNumberOfLines = 0
        self.textView.textContainer.lineBreakMode = .byWordWrapping

        self.textView.add(self.placeholderText)

        self.placeholderText
            .constrainLeft(
                padding: self.textView.textContainerInset.left + self.textView.textContainer.lineFragmentPadding,
                respectSafeArea: false
            )
            .constrainTop(padding: self.textView.textContainerInset.top, respectSafeArea: false)
        self.placeholderText.textColor = UIColor.placeholderText

        self.setFont(to: UIFont.systemFont(ofSize: 56, weight: .bold))
            .setTextColor(to: Colors.textDark)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.textViewDidBeginEditing),
            name: UITextView.textDidBeginEditingNotification,
            object: self.textView
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.textViewDidEndEditing),
            name: UITextView.textDidEndEditingNotification,
            object: self.textView
        )
    }

    // MARK: Functions

    @discardableResult
    public func setOnSubmit(_ callback: ((String) -> Void)?) -> Self {
        self.onSubmit = callback
        return self
    }

    @discardableResult
    public func setOnFocus(_ callback: (() -> Void)?) -> Self {
        self.onFocus = callback
        return self
    }

    @discardableResult
    public func setOnUnfocus(_ callback: (() -> Void)?) -> Self {
        self.onUnfocus = callback
        return self
    }

    @discardableResult
    public func setOnChange(_ callback: ((String) -> Void)?) -> Self {
        self.onChange = callback
        return self
    }

    @discardableResult
    public func setSubmitLabel(to label: UIReturnKeyType) -> Self {
        self.textView.returnKeyType = label
        return self
    }

    @discardableResult
    public func setPlaceholder(to text: String?) -> Self {
        self.placeholderText.setText(to: text)
        self.placeholderText.isHidden = !self.textView.text.isEmpty
        return self
    }

    @discardableResult
    public func setText(to text: String?) -> Self {
        self.textView.text = text
        self.placeholderText.isHidden = !(text ?? "").isEmpty
        return self
    }

    @discardableResult
    public func setTextColor(to color: UIColor) -> Self {
        self.textView.textColor = color
        return self
    }

    @discardableResult
    public func setFont(to font: UIFont?) -> Self {
        self.textView.font = font
        self.placeholderText.setFont(to: font)
        return self
    }

    @discardableResult
    public func setSize(to size: CGFloat) -> Self {
        self.textView.font = self.textView.font?.withSize(size)
        self.placeholderText.setSize(to: size)
        return self
    }

    @discardableResult
    public func setTextAlignment(to alignment: NSTextAlignment) -> Self {
        self.textView.textAlignment = alignment
        return self
    }

    public func textViewDidChange(_ textView: UITextView) {
        self.placeholderText.isHidden = !textView.text.isEmpty
        self.onChange?(self.text)
    }

    @objc
    private func textViewDidBeginEditing(notification: NSNotification) {
        self.onFocus?()
    }

    @objc
    private func textViewDidEndEditing(notification: NSNotification) {
        self.onUnfocus?()
    }
}

/// Auto-sizes to fit its content when no height constraint is set, while still supporting scroll when a height constraint is applied.
/// `UITextView` with `isScrollEnabled = true` has no intrinsic content size by default, so this subclass reports `contentSize` as its intrinsic content size.
private class InternalTextView: UITextView {
    // MARK: Overridden Properties

    public override var intrinsicContentSize: CGSize {
        return self.contentSize
    }

    // MARK: Overridden Functions

    public override func layoutSubviews() {
        super.layoutSubviews()
        self.invalidateIntrinsicContentSize()
    }
}
