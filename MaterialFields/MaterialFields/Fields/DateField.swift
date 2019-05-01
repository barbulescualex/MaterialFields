//
//  DateField.swift
//  MaterialFields
//
//  Created by Alex Barbulescu on 2019-02-01.
//  Copyright © 2019 Alex Barbulescu. All rights reserved.
//

import UIKit

@objc public protocol DateFieldDelegate : AnyObject {
    @objc optional func dateFieldShouldBeginEditing(_ view: DateField) -> Bool
    
    @objc func dateFieldDidEndEditing(_ view: DateField)
    
    @objc optional func dateFieldCleared(_ view: DateField)
    
    @objc optional func dateChanged(_ view: DateField)
}

public class DateField: Field {
    //MARK: UIDATEPICKER VARS
    public var date : Date? {
        didSet{
            if let setDate = date {
                datePicker.date = setDate
                if let df = dateFormatter {
                    entryField.text = df.string(from: date!)
                } else {
                    entryField.text = defaultFormatter.string(from: date!)
                }
            } else {
               entryField.text = nil
            }
        }
    }
    
    private let defaultFormatter : DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "MMM dd, yyyy"
        df.timeZone = TimeZone(abbreviation: "GMT")
        return df
    }()
    
    public var dateFormatter : DateFormatter?
    
    public var datePickerMode : UIDatePicker.Mode? {
        didSet{
            datePicker.datePickerMode = datePickerMode!
        }
    }
    
    public var timeZone : TimeZone? {
        didSet{
            datePicker.timeZone = timeZone
        }
    }
    
    public var locale : Locale? {
        didSet{
            datePicker.locale = locale
        }
    }
    
    public var minimumDate : Date? {
        didSet{
            datePicker.minimumDate = minimumDate
        }
    }
    
    public var defaultDate : Date? {
        didSet{
            if let setDefault = defaultDate {
                datePicker.date = setDefault
                //currentDateInPicker = setDefault
            }
        }
    }
    
    private var defaultDone = false
    
    public var maximumDate : Date? {
        didSet{
            if let date = maximumDate {
                maxDateSet = true
                datePicker.maximumDate = date
            } else {
                maxDateSet = false
            }
        }
    }
    
    private var maxDateSet = false
    
    public var isClearable = false {
        didSet{
            clearButton.isHidden = !isClearable
        }
    }
    
    public override var placeholder : String? {
        didSet {
            entryField.placeholder = placeholder
        }
    }
    
    public override var isOptional : Bool {
        didSet{
            entryField.isOptional = isOptional
        }
    }
    
    //COLORS
    //entryfield
    public override var borderColor: UIColor {
        didSet{
            entryField.borderColor = borderColor
        }
    }
    
    public override var borderHighlightColor: UIColor {
        didSet{ //NEEDS WORK
            entryField.borderHighlightColor = borderHighlightColor
        }
    }
    
    public override var textColor: UIColor {
        didSet{
            entryField.textColor = textColor
        }
    }
    
    public override var placeholderDownColor: UIColor {
        didSet{
            entryField.placeholderDownColor = placeholderDownColor
        }
    }
    
    public override var placeholderUpColor: UIColor {
        didSet{
            entryField.placeholderUpColor = placeholderUpColor
        }
    }
    
    //buttons
    public var clearButtonColor: UIColor = UIColor.materialFieldsBlue{
        didSet{
            clearButton.backgroundColor = clearButtonColor
        }
    }
    
    public var doneButtonColor: UIColor = UIColor.materialFieldsBlue{
        didSet{
            doneButton.backgroundColor = doneButtonColor
        }
    }
    
    
    //MARK:- VARS
    weak public var delegate : DateFieldDelegate?
    
    //MARK:- VIEW COMPONENTS
    private let verticalStack : UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var entryField = EntryField()
    
    private lazy var clearButton : UIButton = {
        let button = UIButton()
        let attributes = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : UIColor.white]
        button.backgroundColor = UIColor.materialFieldsBlue
        button.setAttributedTitle(NSAttributedString(string: "clear", attributes: attributes), for: .normal)
        button.addTarget(self, action: #selector(clearPressed(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.contentEdgeInsets = UIEdgeInsets(top: 3.5, left: 5, bottom: 3.5, right: 5)
        return button
    }()
    
    private lazy var doneButton : UIButton = {
        let button = UIButton()
        let attributes = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : UIColor.white]
        button.backgroundColor = UIColor.materialFieldsBlue
        button.setAttributedTitle(NSAttributedString(string: "done", attributes: attributes), for: .normal)
        button.addTarget(self, action: #selector(donePressed(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.contentEdgeInsets = UIEdgeInsets(top: 3.5, left: 5, bottom: 3.5, right: 5)
        return button
    }()
    
    public lazy var datePicker : UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        return datePicker
    }()
    
    public required init() {
        super.init(frame: .zero)
        setupView()
    }
    
    //initWithCode to init view from xib or storyboard
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    //MARK: SETUP FUNCTIONS
    private func setupView() {
        //fake field
        entryField.delegate = self
        
        entryField.addSubview(clearButton)
        clearButton.centerYAnchor.constraint(equalTo: entryField.centerYAnchor, constant: 5).isActive = true
        clearButton.trailingAnchor.constraint(equalTo: entryField.trailingAnchor, constant: 0).isActive = true
        clearButton.isHidden = true
        
        entryField.addSubview(doneButton)
        doneButton.centerYAnchor.constraint(equalTo: entryField.centerYAnchor, constant: 5).isActive = true
        doneButton.trailingAnchor.constraint(equalTo: entryField.trailingAnchor, constant: 0).isActive = true
        doneButton.isHidden = true
        
        //keeps it over text
        bringSubviewToFront(doneButton)
        bringSubviewToFront(clearButton)
        
        //vertical stack
        verticalStack.addArrangedSubview(entryField)
        verticalStack.addArrangedSubview(datePicker)
        datePicker.isHidden = true
        addSubview(verticalStack)
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(keyboardDidShow(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        
        setupLayout()
    }
    
    private func setupLayout(){
        verticalStack.topAnchor.constraint(equalTo: topAnchor).isActive = true
        verticalStack.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        verticalStack.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        verticalStack.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker){
        if !defaultDone{
            defaultDone = true
        }
        date = sender.date
        delegate?.dateChanged?(self)
    }
    
    //MARK: FUNCTIONS
    private func showDatePicker(){
        if let defaultDate = defaultDate, !defaultDone {
            date = defaultDate
        } else {
            date = datePicker.date
        }
        doneButton.isHidden = false
        clearButton.isHidden = true
        entryField.isEditing(showHighlight: true)
        isActive = true
        datePicker.isHidden = false
    }
    
    
    @objc func donePressed(_ sender: UIButton?){
        entryField.isEditing(showHighlight: false)
        
        datePicker.isHidden = true
        delegate?.dateFieldDidEndEditing(self)
        isActive = false
        
        doneButton.isHidden = true
        clearButton.isHidden = !isClearable
    }
    
    
    @objc func clearPressed(_ sender: UIButton){
        date = nil
        entryField.text = nil
        if let defaultDate = defaultDate {
            datePicker.date = defaultDate
        }
        delegate?.dateFieldCleared?(self)
    }
    
    override public func setError(withText text: String?) {
        entryField.setError(withText: text)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK:- ENTRYFIELD DELEGATE
extension DateField : EntryFieldDelegate {
    public func entryFieldShouldBeginEditing(_ view: EntryField) -> Bool {
        if(isActive){
            return false
        }
        UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
        if let shouldBegin = delegate?.dateFieldShouldBeginEditing?(self) {
            if shouldBegin {
                showDatePicker()
            }
        } else { //assuming user wants to show it
            showDatePicker()
        }
        return false
    }
}

//MARK:- KEYBOARD LISTENER
extension DateField {
    //detect other field opening, means focus was lost on us so close the datePicker
    @objc func keyboardDidShow(_ notification: Notification) {
        if isActive {
            donePressed(nil)
        }
    }
}

