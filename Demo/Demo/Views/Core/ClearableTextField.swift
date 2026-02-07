//
//  ClearableTextField.swift
//  https://github.com/Andre-Pham/Zilliax
//
//  Created by Andre Pham.
//

import UIKit

public class ClearableTextField: View {
    // MARK: Properties

    private let stack = HStack()
    private let textField = InternalTextField()
    private let textClearControl = Control()
    private let textClearIcon = Icon()
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

        self.add(self.stack)

        self.stack
            .constrainAllSides(respectSafeArea: false)
            .setBackgroundColor(to: Colors.fillSecondary)
            .setCornerRadius(to: 16)
            .append(self.textField)
            .append(self.textClearControl)

        self.textField
            .useAutoLayout()
            .setHeightConstraint(to: 50)

        self.textClearControl
            .setSizeConstraint(to: 50)
            .add(self.textClearIcon)
            .setOnRelease({
                self.setText(to: nil)
                self.onChange?("")
                self.textField.becomeFirstResponder()
            })

        self.textClearIcon
            .setSymbol(systemName: "xmark")
            .setWeight(to: .bold)
            .constrainCenter(respectSafeArea: false)
            .setSize(to: 18)
            .setColor(to: Colors.black)
            .setOpacity(to: 0.2)

        self.setFont(to: UIFont.systemFont(ofSize: 18, weight: .medium))
            .setTextColor(to: Colors.textDark)

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

    private let padding = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 0)

    // MARK: Overridden Functions

    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: self.padding)
    }

    public override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: self.padding)
    }
}
