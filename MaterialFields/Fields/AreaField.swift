//
//  AreaField.swift
//  MaterialFields
//
//  Created by Alex Barbulescu on 2019-03-29.
//  Copyright © 2019 Alex Barbulescu. All rights reserved.
//

import UIKit

@objc protocol AreaFieldDelegate : AnyObject {
    @objc optional func areaFieldShouldBeginEditing(_ view: AreaField) -> Bool
    
    @objc optional func areaFieldDidBeginEditing(_ view: AreaField)
    
    @objc optional func areaFieldShouldEndEditing(_ view: AreaField) -> Bool
    
    @objc optional func areaFieldDidEndEditing(_ view: AreaField)
}

class AreaField: Field, UIGestureRecognizerDelegate {
    //MARK:- TEXTVIEW VARS
    public var placeholder : String? {
        didSet{
            if (isOptional && placeholder.isComplete()) {
                placeholderLabel.text = placeholder! + " (Optional)"
            }
            placeholderLabel.text = placeholder
        }
    }
    
    public var text: String? {
        get{
            return textView.text
        }
        set{
            textView.text = newValue
            if newValue.isComplete() {
                animatePlaceholder(up: true)
            } else {
                animatePlaceholder(up: false)
            }
        }
    }
    
    //COLORS
    public var borderColor: UIColor = UIColor.lightGray {
        didSet{
            if !isActive && !hasError {
                updateBorderColor(with: borderColor)
            }
        }
    }
    
    public var borderHighlightColor: UIColor = UIColor.babyBlue {
        didSet{
            if isActive {
                updateBorderColor(with: borderHighlightColor)
            }
        }
    }
    
    public var borderErrorColor: UIColor = UIColor.red {
        didSet{
            if hasError {
                updateBorderColor(with: borderErrorColor)
            }
        }
    }
    
    public var textColor: UIColor = UIColor.black {
        didSet{
            textView.textColor = textColor
        }
    }
    
    public var errorTextColor: UIColor = UIColor.red {
        didSet{
            errorLabel.textColor = errorTextColor
        }
    }
    
    public var placeholderDownColor: UIColor = UIColor.gray {
        didSet{
            if !placeholderUp {
                placeholderLabel.textColor = placeholderDownColor
            }
        }
    }
    
    public var placeholderUpColor: UIColor = UIColor.black {
        didSet{
            if placeholderUp {
                placeholderLabel.textColor = placeholderUpColor
            }
        }
    }
    
    public var cursorColor: UIColor = UIColor.black.withAlphaComponent(0.5) {
        didSet{
            textView.tintColor = cursorColor
        }
    }
    
    
    //OPTIONALS
    public var isOptional : Bool = false {
        didSet{
            if let placeholder = placeholder {
                placeholderLabel.text = placeholder + " (Optional)"
            }
        }
    }
    
    public var shakes : Bool = true
    
    public var isViewAreaInteractable : Bool = true {
        didSet{
            textView.isUserInteractionEnabled = isViewAreaInteractable
        }
    }
    
    public var keyboardType: UIKeyboardType? {
        didSet{
            guard let type = keyboardType else {return}
            textView.keyboardType = type
        }
    }
    
    public var autocapitalizationType : UITextAutocapitalizationType = .none {
        didSet{
            textView.autocapitalizationType = autocapitalizationType
        }
    }
    
    public var autocorrectionType : UITextAutocorrectionType = .default {
        didSet{
            textView.autocorrectionType = autocorrectionType
        }
    }
    
    //MARK:- VARS
    weak var delegate : AreaFieldDelegate?
    
    private var placeholderYAnchorConstraint: NSLayoutConstraint!
    private var placeholderUp = false
    private(set) var hasError = false
    private var isActive = true
    
    //MARK:- VIEW COMPONENTS
    private let stackView : UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let placeholderPlaceholder : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = "Subscribe to PewDiePie"
        label.textColor = UIColor.clear
        return label
    }()
    
    public let placeholderLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .gray
        label.alpha = 0.5
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    public lazy var textView : UITextView = {
        let textView = UITextView()
        textView.textAlignment = .left
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.tintColor = UIColor.black.withAlphaComponent(0.5)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.autocorrectionType = .no
        textView.isEditable = true
        textView.isScrollEnabled = false
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 1, right: 0)
        textView.textContainer.lineFragmentPadding = 0
        return textView
    }()
    
    private let borderTop : UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return view
    }()
    
    private let borderBottom : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return view
    }()
    
    public let errorLabel : UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    //MARK:- INIT
    override init(frame: CGRect){
        super.init(frame: .zero)
        setup()
    }
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup(){
        translatesAutoresizingMaskIntoConstraints = false
        textView.delegate = self
        
        //stack and placeholder
        addSubview(stackView)
        stackView.addArrangedSubview(placeholderPlaceholder)
        stackView.addArrangedSubview(textView)
        
        //shadow
        let shadowStack = UIStackView()
        shadowStack.axis = .vertical
        shadowStack.addArrangedSubview(borderTop)
        shadowStack.addArrangedSubview(borderBottom)
        shadowStack.distribution = .fillEqually
        stackView.addArrangedSubview(shadowStack)
        stackView.setCustomSpacing(0, after: textView)
        
        //error label
        stackView.addArrangedSubview(errorLabel)
        errorLabel.isHidden = true
        
        //stack constraints
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        //placeholder constraints
        addSubview(placeholderLabel)
        placeholderYAnchorConstraint = placeholderLabel.centerYAnchor.constraint(equalTo: textView.centerYAnchor, constant: -1)
        placeholderPlaceholder.leadingAnchor.constraint(equalTo: textView.leadingAnchor).isActive = true
        placeholderYAnchorConstraint.isActive = true
        
        //tap gesture recognizer
        let tap = UITapGestureRecognizer(target: self, action: #selector(startEditing(_:)))
        tap.delegate = self
        self.addGestureRecognizer(tap)
    }
    
    //MARK:- FUNCTIONS
    fileprivate func updateBorderColor(with color: UIColor){
        borderTop.backgroundColor = color
        borderBottom.backgroundColor = color.withAlphaComponent(0.5)
    }
    
    fileprivate func isEditing(showHighlight val: Bool){
        if hasError {return}
        if val {
            updateBorderColor(with: borderHighlightColor)
        } else {
            updateBorderColor(with: borderColor)
        }
    }
    
    func removeErrorUI(){
        if(hasError){
            textView.textColor = textColor
            updateBorderColor(with: borderColor)
            placeholderLabel.textColor = placeholderUpColor
            hasError = false
            errorLabel.text = nil
            errorLabel.isHidden = false
        }
    }
    
    @objc func startEditing(_ sender: UIGestureRecognizer){
        textView.becomeFirstResponder()
    }
    
    override func setError(withText text: String?) {
        hasError = true
        updateBorderColor(with: borderErrorColor)
        textView.textColor = borderErrorColor
        
        if(!placeholderUp){
            placeholderLabel.textColor = errorTextColor
        }
        
        if shakes {
            let shake = CABasicAnimation(keyPath: "position")
            shake.duration = 0.05
            shake.repeatCount = 2
            shake.autoreverses = true
            shake.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 10, y: self.center.y))
            shake.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 10, y: self.center.y))
            self.layer.add(shake, forKey: "position")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.errorLabel.text = text
                self.errorLabel.isHidden = false
            }
        } else {
            self.errorLabel.text = text
            self.errorLabel.isHidden = false
        }
    }
}

//MARK:- TEXTVIEW DELEGATE
extension AreaField : UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return delegate?.areaFieldShouldBeginEditing?(self) ?? true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        isActive = true
        removeErrorUI()
        animatePlaceholder(up: true)
        isEditing(showHighlight: true)
        delegate?.areaFieldDidBeginEditing?(self)
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return delegate?.areaFieldShouldEndEditing?(self) ?? true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if(textView.text.isNotComplete()){
            animatePlaceholder(up: false)
        }
        delegate?.areaFieldDidEndEditing?(self)
        isEditing(showHighlight: false)
        isActive = false
    }
}

//MARK:- ANIMATIONS
extension AreaField {
    func animatePlaceholder(up: Bool) {
        if(up){
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.placeholderLabel.textColor = self.placeholderUpColor
                self.placeholderYAnchorConstraint.isActive = false
                self.placeholderYAnchorConstraint = self.placeholderLabel.centerYAnchor.constraint(equalTo: self.placeholderPlaceholder.centerYAnchor)
                self.placeholderYAnchorConstraint.isActive = true
                self.placeholderLabel.font = UIFont.systemFont(ofSize: 12)
                self.placeholderLabel.alpha = 0.7
                self.layoutIfNeeded()
            }, completion: { (Bool) in
                self.placeholderUp = true
            })
        } else {//down
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.placeholderLabel.textColor = self.placeholderDownColor
                self.placeholderYAnchorConstraint.isActive = false
                self.placeholderYAnchorConstraint = self.placeholderLabel.centerYAnchor.constraint(equalTo: self.textView.centerYAnchor, constant: -1)
                self.placeholderYAnchorConstraint.isActive = true
                self.placeholderLabel.font = UIFont.systemFont(ofSize: 18)
                self.placeholderLabel.alpha = 0.5
                self.layoutIfNeeded()
            }, completion: { (Bool) in
                self.placeholderUp = false
            })
        }
    }
}
