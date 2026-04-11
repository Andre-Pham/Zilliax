//
//  TextArea.swift
//  https://github.com/Andre-Pham/Zilliax
//
//  Created by Andre Pham.
//

import UIKit

public class TextArea: View, UITextViewDelegate {
    // MARK: Properties

    private let textView = UITextView()
    private let placeholderText = Text()
    private var onSubmit: ((String) -> Void)? = nil
    private var onFocus: (() -> Void)? = nil
    private var onUnfocus: (() -> Void)? = nil
    private var onChange: ((String) -> Void)? = nil
    private var placeholderHiddenOnFocus = false

    // MARK: Computed Properties

    public var text: String {
        return self.textView.text ?? ""
    }

    private var isPlaceholderHidden: Bool {
        return !self.textView.text.isEmpty || (self.placeholderHiddenOnFocus && self.textView.isFirstResponder)
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

        let textContainer = self.textView.textContainer
        let textContainerInset = self.textView.textContainerInset

        let horizontalPadding = textContainerInset.left + textContainer.lineFragmentPadding
        self.placeholderText.leadingAnchor.constraint(
            equalTo: self.textView.frameLayoutGuide.leadingAnchor,
            constant: horizontalPadding
        ).isActive = true
        self.placeholderText.trailingAnchor.constraint(
            equalTo: self.textView.frameLayoutGuide.trailingAnchor,
            constant: -horizontalPadding
        ).isActive = true
        self.placeholderText
            .constrainTop(padding: textContainerInset.top, respectSafeArea: false)
            .setTextColor(to: .placeholderText)

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
        self.placeholderText
            .setText(to: text)
            .setHidden(to: self.isPlaceholderHidden)
        return self
    }

    @discardableResult
    public func setPlaceholderHiddenOnFocus(to hidden: Bool) -> Self {
        self.placeholderHiddenOnFocus = hidden
        return self
    }

    @discardableResult
    public func setText(to text: String?) -> Self {
        self.textView.text = text
        self.placeholderText.setHidden(to: self.isPlaceholderHidden)
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
        self.placeholderText.setTextAlignment(to: alignment)
        return self
    }

    public func textViewDidChange(_ textView: UITextView) {
        self.placeholderText.setHidden(to: self.isPlaceholderHidden)
        self.onChange?(self.text)
    }

    @objc
    private func textViewDidBeginEditing(notification: NSNotification) {
        self.placeholderText.setHidden(to: self.isPlaceholderHidden)
        self.onFocus?()
    }

    @objc
    private func textViewDidEndEditing(notification: NSNotification) {
        self.placeholderText.setHidden(to: self.isPlaceholderHidden)
        self.onUnfocus?()
    }
}
