//
//  TextField.swift
//  https://github.com/Andre-Pham/Zilliax
//
//  Created by Andre Pham.
//

import UIKit

public class TextField: View {
    // MARK: Properties

    private let textField = InternalTextField()
    private var onSubmit: ((String) -> Void)? = nil
    private var onFocus: (() -> Void)? = nil
    private var onUnfocus: (() -> Void)? = nil
    private var onChange: ((String) -> Void)? = nil

    // MARK: Computed Properties

    public var text: String {
        return self.textField.text ?? ""
    }

    // MARK: Overridden Functions

    public override func setup() {
        super.setup()

        self.add(self.textField)

        self.textField
            .useAutoLayout()
            .constrainAllSides(respectSafeArea: false)

        self.setFont(to: UIFont.systemFont(ofSize: 18, weight: .medium))
            .setTextColor(to: Colors.textDark)
            .setBackgroundColor(to: Colors.fillSecondary)
            .setCornerRadius(to: 16)
            .setHeightConstraint(to: 50)

        self.textField.addTarget(self, action: #selector(self.handleSubmit), for: .editingDidEndOnExit)
        self.textField.addTarget(self, action: #selector(self.handleTextChanged), for: .editingChanged)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.textFieldDidBeginEditing),
            name: UITextField.textDidBeginEditingNotification,
            object: self.textField
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.textFieldDidEndEditing),
            name: UITextField.textDidEndEditingNotification,
            object: self.textField
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
        self.textField.returnKeyType = label
        return self
    }

    @discardableResult
    public func setPlaceholder(to text: String?) -> Self {
        self.textField.placeholder = text
        return self
    }

    @discardableResult
    public func setText(to text: String?) -> Self {
        self.textField.text = text
        return self
    }

    @discardableResult
    public func setTextColor(to color: UIColor) -> Self {
        self.textField.textColor = color
        return self
    }

    @discardableResult
    public func setFont(to font: UIFont?) -> Self {
        self.textField.font = font
        return self
    }

    @discardableResult
    public func setSize(to size: CGFloat) -> Self {
        self.textField.font = self.textField.font?.withSize(size)
        return self
    }

    @discardableResult
    public func setTextAlignment(to alignment: NSTextAlignment) -> Self {
        self.textField.textAlignment = alignment
        return self
    }

    @objc
    private func handleSubmit() {
        self.onSubmit?(self.text)
    }

    @objc
    private func handleTextChanged() {
        self.onChange?(self.text)
    }

    @objc
    private func textFieldDidBeginEditing(notification: NSNotification) {
        self.onFocus?()
    }

    @objc
    private func textFieldDidEndEditing(notification: NSNotification) {
        self.onUnfocus?()
    }
}

private class InternalTextField: UITextField {
    // MARK: Properties

    private let padding = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)

    // MARK: Overridden Functions

    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: self.padding)
    }

    public override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: self.padding)
    }
}
