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
    private let scrollUpButton = IconButton()
    private let scrollDownButton = IconButton()
    private var onSubmit: ((String) -> Void)? = nil
    private var onFocus: (() -> Void)? = nil
    private var onUnfocus: (() -> Void)? = nil
    private var onChange: ((String) -> Void)? = nil
    private var placeholderHiddenOnFocus = false
    private var scrollButtonsEnabled = true
    private var maxCharacters: Int? = nil
    private var placeholderHorizontalConstraints: (left: NSLayoutConstraint, right: NSLayoutConstraint)?
    private var placeholderTopConstraint: NSLayoutConstraint?

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

        self.textView.delegate = self

        self.configure(isScrollEnabled: true, maxLines: 0, lineBreakMode: .byWordWrapping)
            .add(self.textView)
            .add(self.scrollUpButton)
            .add(self.scrollDownButton)

        self.textView
            .useAutoLayout()
            .constrainAllSides(layoutGuide: .view)
            .setBackgroundColor(to: .clear)
            .add(self.placeholderText)

        let textContainer = self.textView.textContainer
        let textContainerInset = self.textView.textContainerInset
        let horizontalPadding = textContainerInset.left + textContainer.lineFragmentPadding

        self.placeholderHorizontalConstraints = self.placeholderText
            .constrainHorizontalValue(to: self.textView, padding: horizontalPadding, layoutGuide: .frame)
        self.placeholderTopConstraint = self.placeholderText
            .constrainTopValue(padding: textContainerInset.top, layoutGuide: .view)
        self.placeholderText
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

        for button in [self.scrollUpButton, self.scrollDownButton] {
            if #available(iOS 26.0, *) {
                UIVisualEffectView(effect: UIGlassEffect())
                    .useAutoLayout()
                    .addAsSubview(of: button, at: 0)
                    .constrainAllSides(layoutGuide: .view)
                    .setInteractions(enabled: false)
            } else {
                UIVisualEffectView(effect: UIBlurEffect(style: .regular))
                    .useAutoLayout()
                    .addAsSubview(of: button, at: 0)
                    .constrainAllSides(layoutGuide: .view)
                    .setInteractions(enabled: false)
                    .setOpacity(to: 0.75)
            }
            button.setClipsToBounds(to: true)
        }

        self.scrollUpButton
            .constrainTop(padding: 8, layoutGuide: .view)
            .constrainRight(padding: 12, layoutGuide: .view)
            .setSizeConstraint(to: 36)
            .setIcon(to: Icon.Config(systemName: "chevron.up", size: 16, weight: .bold, color: Colors.textDark))
            .setOnTap { [weak self] in
                self?.textView.setContentOffset(.zero, animated: true)
            }
            .setHidden(to: true)

        self.scrollDownButton
            .constrainBottom(padding: 8, layoutGuide: .view)
            .constrainRight(padding: 12, layoutGuide: .view)
            .setSizeConstraint(to: 36)
            .setIcon(to: Icon.Config(systemName: "chevron.down", size: 16, weight: .bold, color: Colors.textDark))
            .setOnTap { [weak self] in
                guard let self else {
                    return
                }
                let bottomOffset = CGPoint(
                    x: 0,
                    y: self.textView.contentSize.height - self.textView.bounds.height + self.textView.contentInset.bottom
                )
                self.textView.setContentOffset(bottomOffset, animated: true)
            }
            .setHidden(to: true)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        self.updateScrollIndicators()
    }

    // MARK: Functions

    @discardableResult
    public func configure(isScrollEnabled: Bool, maxLines: Int, lineBreakMode: NSLineBreakMode) -> Self {
        self.textView.isScrollEnabled = isScrollEnabled
        self.textView.textContainer.maximumNumberOfLines = maxLines
        self.textView.textContainer.lineBreakMode = lineBreakMode
        return self
    }

    @discardableResult
    public func fitTextToContainer() -> Self {
        self.textView.textContainerInset = .zero
        self.textView.textContainer.lineFragmentPadding = 0.0
        self.placeholderHorizontalConstraints?.left.constant = 0.0
        self.placeholderHorizontalConstraints?.right.constant = 0.0
        self.placeholderTopConstraint?.constant = 0.0
        return self
    }

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
    public func setScrollButtons(enabled: Bool) -> Self {
        self.scrollButtonsEnabled = enabled
        if !enabled {
            self.scrollUpButton.setHidden(to: true)
            self.scrollDownButton.setHidden(to: true)
        } else {
            self.updateScrollIndicators()
        }
        return self
    }

    @discardableResult
    public func setMaxCharacters(to max: Int?) -> Self {
        self.maxCharacters = max
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

    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // If the user taps the submit button (text is "\n") and onSubmit is defined, trigger the submit callback and close
        // Otherwise, behave as normal
        if text == "\n", let onSubmit = self.onSubmit {
            onSubmit(self.text)
            return false
        }
        if let maxCharacters = self.maxCharacters {
            let currentText = textView.text ?? ""
            guard let stringRange = Range(range, in: currentText) else {
                return false
            }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
            return updatedText.count <= maxCharacters
        }
        return true
    }

    public func textViewDidChange(_ textView: UITextView) {
        self.placeholderText.setHidden(to: self.isPlaceholderHidden)
        self.onChange?(self.text)
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.updateScrollIndicators()
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

    private func updateScrollIndicators() {
        let offset = self.textView.contentOffset.y
        let contentHeight = self.textView.contentSize.height
        let visibleHeight = self.textView.bounds.height
        guard self.scrollButtonsEnabled, contentHeight.isGreater(than: visibleHeight) else {
            self.scrollUpButton.setHidden(to: true)
            self.scrollDownButton.setHidden(to: true)
            return
        }
        let maxOffset = contentHeight - visibleHeight
        self.scrollUpButton.setHidden(to: offset.isLessOrEqualZero())
        self.scrollDownButton.setHidden(to: offset.isGreaterOrEqual(to: maxOffset))
    }
}
