//
//  DateField.swift
//  MaterialFields
//
//  Created by Alex Barbulescu on 2019-02-01.
//  Copyright © 2019 Alex Barbulescu. All rights reserved.
//

import UIKit

/// PickerFieldDelegate protocol. Forwards editing state changes and content changes.
@objc public protocol DateFieldDelegate : AnyObject {
    /// Asks the delegate if editing should begin in the specified DateField.
    /// - Parameter view: The DateField that called the delegate method.
    @objc optional func dateFieldShouldBeginEditing(_ view: DateField) -> Bool
    
    /// Tells the delegate editing ended in the specified DateField.
    /// - Parameter view: The DateField that called the delegate method.
    @objc func dateFieldDidEndEditing(_ view: DateField)
    
    /// Tells the delegate that the contents have been cleared in the specified DateField.
    /// - Parameter view: The DateField that called the delegate method.
    @objc optional func dateFieldCleared(_ view: DateField)
    
    /// Tells the delegate that a row was selected in the specified DateField.
    /// - Parameter view: The DateField that called the delegate method.
    /// - Parameter row: The row that was selected.
    @objc optional func dateChanged(_ view: DateField)
}

/// Material version of the UIDatePicker
public class DateField: Field {
    //MARK: Vars
    
    /// Date value currently held by field.
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
    
    /// The defualt date formatter to populate the entry field with.
    private let defaultFormatter : DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "MMM dd, yyyy"
        df.timeZone = TimeZone(abbreviation: "GMT")
        return df
    }()
    
    /// The dateFormatter you want to use to display the date in the field. Defaults to "MMM dd, yyyy"
    public var dateFormatter : DateFormatter?
    
    /// The date picker mode for the field.
    public var datePickerMode : UIDatePicker.Mode? {
        didSet{
            datePicker.datePickerMode = datePickerMode!
        }
    }
    
    /// The timezone for the field.
    public var timeZone : TimeZone? {
        didSet{
            datePicker.timeZone = timeZone
        }
    }
    
    /// The locale for the field.
    public var locale : Locale? {
        didSet{
            datePicker.locale = locale
        }
    }
    
    /// The minimum date for the field.
    public var minimumDate : Date? {
        didSet{
            datePicker.minimumDate = minimumDate
        }
    }
    
    /// The default date of the field.
    public var defaultDate : Date? {
        didSet{
            if let setDefault = defaultDate {
                datePicker.date = setDefault
                //currentDateInPicker = setDefault
            }
        }
    }
    
    /// Private flag to check if default date has been displayed.
    private var defaultDone = false
    
    /// The maximum date of the field.
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
    
    /// Private flag to check if the max date has been set.
    private var maxDateSet = false
    
    /// Setter for showing a clear button to eliminate the contents of the field.
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
    
    //MARK: Colors
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
    
    
    //MARK: Delegate
    /// The reciever's delegate
    weak public var delegate : DateFieldDelegate?
    
    public override var shakes: Bool {
        didSet{
            entryField.shakes = shakes
        }
    }
    
    //MARK: View Components
    /// The stackview that encompasses the whole view
    private let verticalStack : UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    /// The EntryField behind this field class
    private lazy var entryField = EntryField()
    
    /// The clear button for emptying contents of the field if isClearable is set to true.
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
    
    /// The done button for closing the picker.
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
    
    /// The UIPickerView behind this field class
    private lazy var datePicker : UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        return datePicker
    }()
    
    //MARK: Init
    /**
     Required initializer if doing programtically. You can manually set the frame after initialization. Otherwise it relies on auto layout and its intrinsic content size.
     - Warning: Refer to the Field Guide in the online documentation if you want to define height constraints.
     */
    public required init() {
        super.init(frame: .zero)
        setup()
    }
    
    //initWithCode to init view from xib or storyboard
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    //MARK: Setup Functions
    /// Sets up the view.
    private func setup() {
        //fake field
        entryField.delegate = self
        
        entryField.addSubview(clearButton)
        clearButton.centerYAnchor.constraint(equalTo: entryField.textField.centerYAnchor, constant: -3.5).isActive = true
        clearButton.trailingAnchor.constraint(equalTo: entryField.trailingAnchor, constant: 0).isActive = true
        clearButton.isHidden = true
        
        entryField.addSubview(doneButton)
        doneButton.centerYAnchor.constraint(equalTo: entryField.textField.centerYAnchor, constant: -3.5).isActive = true
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
        verticalStack.topAnchor.constraint(equalTo: topAnchor).isActive = true
        verticalStack.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        verticalStack.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        verticalStack.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(keyboardDidShow(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    // Callback function for the date being changed.
    @objc private func dateChanged(_ sender: UIDatePicker){
        if !defaultDone{
            defaultDone = true
        }
        date = sender.date
        if hasError {
            removeErrorUI()
        }
        delegate?.dateChanged?(self)
    }
    
    //MARK: Error Functions
    /// Opens the picker. Clears any error state.
    private func showDatePicker(){
        if hasError{
            removeErrorUI()
        }
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
    
    /// Callback for the done button being pressed. Is also called manaully. Closes the picker and resets the state to normal unless it is in an error state.
    @objc func donePressed(_ sender: UIButton?){
        entryField.isEditing(showHighlight: false)
        
        datePicker.isHidden = true
        delegate?.dateFieldDidEndEditing(self)
        isActive = false
        
        doneButton.isHidden = true
        clearButton.isHidden = !isClearable
    }
    
    /// Callback for the clear button being pressed if isClearable is set to true.
    @objc func clearPressed(_ sender: UIButton){
        date = nil
        entryField.text = nil
        if let defaultDate = defaultDate {
            datePicker.date = defaultDate
        }
        if hasError {
            removeErrorUI()
        }
        delegate?.dateFieldCleared?(self)
    }
    
    override public func setError(withText text: String?) {
        entryField.setError(withText: text)
        hasError = true
    }
    
    public override func removeErrorUI() {
        entryField.removeErrorUI()
        hasError = false
    }
    
    //MARK: Responder Functions/Vars
    /**
     Notifies the field that it has been asked to relinquish its status as first responder in its window.
     This triggers the end callback from the field, closes the picker, and removes the editing state.
     - Note: If it's in an error state it will keep its error UI.
     - Returns: true
     */
    override public func resignFirstResponder() -> Bool {
        donePressed(nil)
        return true
    }
    
    /**
     Opens the picker.
     - Returns: true
     */
    override public func becomeFirstResponder() -> Bool {
        showDatePicker()
        return true
    }
    
    ///Returns isActive flag.
    override public var isFirstResponder: Bool {
        return isActive
    }
    
    ///Returns true
    public override var canBecomeFirstResponder: Bool {
        return true
    }
    
    //MARK: Deinit
    /// Removes observers.
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK: EntryField Delegate
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

//MARK: Keyboard Listener
extension DateField {
    /// Detects other fields opening, means focus was lost on us so it closes itself and triggers the endEditing callback.
    @objc func keyboardDidShow(_ notification: Notification) {
        if isActive {
            donePressed(nil)
        }
    }
}

