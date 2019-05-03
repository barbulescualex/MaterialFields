//
//  MissionDateProperty.swift
//  MaterialFields
//
//  Created by Alex Barbulescu on 2019-02-01.
//  Copyright © 2019 Alex Barbulescu. All rights reserved.
//

import UIKit

/// PickerFieldDelegate protocol. Forwards editing state changes and content changes.
@objc public protocol PickerFieldDelegate : AnyObject {
    
    /// Asks the delegate if editing should begin in the specified PickerField.
    /// - Parameter view: The PickerField that called the delegate method.
    @objc optional func pickerFieldShouldBeginEditing(_ view: PickerField) -> Bool
    
    /// Tells the delegate editing ended in the specified PickerField.
    /// - Parameter view: The PickerField that called the delegate method.
    @objc func pickerFieldDidEndEditing(_ view: PickerField)
    
    /// Tells the delegate that the contents have been cleared in the specified PickerField.
    /// - Parameter view: The PickerField that called the delegate method.
    @objc optional func pickerFieldCleared(_ view: PickerField)
    
    /// Tells the delegate that a row was selected in the specified PickerField.
    /// - Parameter view: The PickerField that called the delegate method.
    /// - Parameter row: The row that was selected.
    @objc optional func pickerField(_ view: PickerField, didSelectRow row: Int)
}

/// Material version of the UIPickerView (single column only, supports manual entry)
public class PickerField: Field {
    //MARK:- UIPICKER VARS
    /// Setter for showing a clear button to eliminate the contents of the field.
    public var isClearable = false {
        didSet{
            clearButton.isHidden = !isClearable
        }
    }
    
    /// Picker data source.
    public var data : [String] {
        didSet {
            if isManualEntryCapable && !manualEntrySet{
                manualEntrySet = true
                data.append(manualEntryOptionName)
                pickerView.reloadAllComponents()
                return
            }
            if isManualEntryCapable && manualEntrySet {
                guard let removeIndex = manualEntryIndex else {return}
                data.remove(at: removeIndex)
                data.append(manualEntryOptionName)
                manualEntryIndex = data.count - 1
                pickerView.reloadAllComponents()
                return
            }
            if indexSet {
                entryField.text = data[setIndexTo]
                pickerView.reloadAllComponents()
                return
            }
        }
    }
    
    public override var placeholder : String? {
        didSet {
            entryField.placeholder = placeholder!
        }
    }
    
    public override var isOptional : Bool {
        didSet{
            entryField.isOptional = isOptional
        }
    }
    
    override public var text: String? {
        didSet{
            entryField.text = text
        }
    }
    
    /// Changes index in PickerField. If value is below the lower bound (0), it defualts to 0. If the value is over the upper bound, it defaults to to the upper bound.
    public var setIndexTo : Int = 0 {
        didSet{
            if setIndexTo < 0 {
                setIndexTo = 0
            }
            if setIndexTo > (data.count - 1) {
                setIndexTo = data.count - 1
            }
            pickerView.selectRow(setIndexTo, inComponent: 0, animated: true)
            indexSelected = setIndexTo
            indexSet = true
        }
    }
    
    /// Private flag to check if the index has been set
    private var indexSet = false {
        didSet{
            if data.indices.contains(setIndexTo){
                if !isOnManualEntry{
                    entryField.text = data[setIndexTo]
                }
            }
        }
    }
    
    /// Specifies if the PickerField supports manual entry which will show up as the last option in the picker.
    public var isManualEntryCapable : Bool = false {
        didSet{
            if isManualEntryCapable {
                manualEntrySet = true
                data.append(manualEntryOptionName)
                manualEntryIndex = data.count - 1
            } else {
                manualEntrySet = false
                guard let index = manualEntryIndex else {return}
                data.remove(at: index)
                manualEntryIndex = nil
                isOnManualEntry = false
            }
            pickerView.reloadAllComponents()
        }
    }
    
    public override var keyboardType: UIKeyboardType {
        didSet{
            entryField.keyboardType = keyboardType
        }
    }
    
    public override var autocapitalizationType : UITextAutocapitalizationType {
        didSet{
            entryField.autocapitalizationType = autocapitalizationType
        }
    }
    
    public override var autocorrectionType : UITextAutocorrectionType {
        didSet{
            entryField.autocorrectionType = autocorrectionType
        }
    }
    
    public override var isSecureTextEntry: Bool {
        didSet{
            entryField.isSecureTextEntry = isSecureTextEntry
        }
    }
    /// Specifies the manual entry option name if isManualEntryCapable is set to true
    /// - Note: Defaults to "Manual Entry".
    public var manualEntryOptionName = "Manual Entry" {
        didSet {
            if manualEntrySet {
                guard let index = manualEntryIndex else {return}
                data.remove(at: index)
                data.append(manualEntryOptionName)
                if isOnManualEntry {
                    setIndexToManual()
                }
            }
        }
    }
    /// Flag to check if the manual entry has been set
    private var manualEntrySet = false
    
    /// Index of manual entry row in picker
    private var manualEntryIndex : Int?
    
    /// Read-only integer value for the current index the picker is on
    private(set) var indexSelected : Int = 0 {
        didSet{
            if let manualEntryIndex = manualEntryIndex, indexSelected == manualEntryIndex {
                isOnManualEntry = true
            } else {
                isOnManualEntry = false
            }
        }
    }
    
    /// Flag to check if the picker is currently on manual entry
    private var isOnManualEntry = false {
        didSet{
            if !isOnManualEntry {
                _ = entryField.resignFirstResponder()
            }
        }
    }
    
    /// Setter function to set the PickerField to its manaul entry row
    public func setIndexToManual(){
        if isManualEntryCapable && manualEntrySet {
            guard let index = manualEntryIndex else {return}
            setIndexTo = index
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
    
    public override var borderErrorColor: UIColor {
        didSet{
            entryField.borderErrorColor = borderErrorColor
        }
    }
    
    public override var textColor: UIColor {
        didSet{
            entryField.textColor = textColor
        }
    }
    
    public override var errorTextColor: UIColor {
        didSet{
            entryField.errorTextColor = errorTextColor
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
    
    public override var cursorColor: UIColor {
        didSet{
            entryField.cursorColor = cursorColor
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
    
    //MARK: VARS
    
    /// The reciever's delegate
    weak public var delegate : PickerFieldDelegate?
    
    public override var shakes: Bool {
        didSet{
            entryField.shakes = shakes
        }
    }
    
    //MARK: VIEW COMPONENTS
    
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
    private var entryField = EntryField()
    
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
    private lazy var pickerView : UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.showsSelectionIndicator = true
        pickerView.delegate = self
        pickerView.dataSource = self
        return pickerView
    }()
    
    //MARK:- INIT
    public required init() {
        self.data = []
        super.init(frame: .zero)
        setup()
    }
    
    //initWithCode to init view from xib or storyboard
    required init?(coder aDecoder: NSCoder) {
        self.data = []
        super.init(coder: aDecoder)
        setup()
    }
    
    //MARK: SETUP FUNCTIONS
    /// Sets up the view.
    private func setup() {
        // entry field
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
        
        // picker view
        pickerView.reloadAllComponents()
        
        // vertical stack
        verticalStack.addArrangedSubview(entryField)
        verticalStack.addArrangedSubview(pickerView)
        
        // default visibility
        pickerView.isHidden = true
        
        //vertical stack
        addSubview(verticalStack)
        verticalStack.topAnchor.constraint(equalTo: topAnchor).isActive = true
        verticalStack.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        verticalStack.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        verticalStack.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        //Keyboard listener
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    //MARK:- FUNCTIONS
    /// Callback for the done button being pressed. Is also called manaully. Closes the picker and keyboard if it was on manual entry and resets the state to normal unless it is in an error state.
    @objc internal func donePressed(_ sender: UIButton?){
        pickerView.isHidden = true
        if !isOnManualEntry {
            text = data[indexSelected]
        }
        entryField.endEditing(true)
        delegate?.pickerFieldDidEndEditing(self)
        isActive = false
        entryField.isEditing(showHighlight: false)
        doneButton.isHidden = true
        clearButton.isHidden = !isClearable
    }
    
    /// Opens the picker. Clears any error state. If it was last on manual entry it opens the keyboard.
    private func showPickerView(){
        if isActive {return}
        if data.count == 0 {return}
        if hasError {
            removeErrorUI()
        }
        doneButton.isHidden = false
        clearButton.isHidden = true
        isActive = true
        if isOnManualEntry {
            _ = entryField.becomeFirstResponder()
        } else {
            entryField.text = data[indexSelected]
        }
        pickerView.isHidden = false
        entryField.isEditing(showHighlight: true)
    }
    
    public override func setError(withText text: String?) {
        entryField.setError(withText: text)
        hasError = true
    }
    
    public override func removeErrorUI() {
        entryField.removeErrorUI()
        hasError = false
    }
    
    /// Callback for the clear button being pressed if isClearable is set to true.
    @objc func clearPressed(_ sender: UIButton){
        text = nil
        if hasError {
            removeErrorUI()
        }
        delegate?.pickerFieldCleared?(self)
    }
    
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
     Opens the picker or the PickerField is on manual entry it will open the keyboard.
     - Returns: true
     */
    override public func becomeFirstResponder() -> Bool {
        showPickerView()
        return true
    }
    
    ///Asks to see if the field is the first responder. If it is on manual entry it asks the entryField if it is the responder otherwise it returns its isActive flag
    override public var isFirstResponder: Bool {
        if isOnManualEntry {
            return entryField.isFirstResponder
        } else {
            return isActive
        }
    }
    
    /**
    Returns a boolean indicating wether the field can become the first responder by asking the entryField if it can become the first responder
    - Note: Only use this if your PickerField is manualEntryCapable
    */
    public override var canBecomeFirstResponder: Bool {
        return entryField.canBecomeFirstResponder
    }
    
    /// Removes observers.
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK:- UIPICKERDELEGATE
extension PickerField: UIPickerViewDelegate, UIPickerViewDataSource {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return data.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return data[row]
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.indexSelected = row
        if isOnManualEntry {
            text = nil
            _ = entryField.becomeFirstResponder()
        } else {
            text = data[row]
        }
        if hasError {
            removeErrorUI()
        }
        delegate?.pickerField?(self, didSelectRow: row)
    }
}

//MARK:- ENTRY FIELD DELEGATE
extension PickerField : EntryFieldDelegate {
    public func entryFieldShouldBeginEditing(_ view: EntryField) -> Bool {
        //print("entry field should begin editing")
        if let shouldBegin = delegate?.pickerFieldShouldBeginEditing?(self) {
            if !shouldBegin {
                return false
            }
        }
        if isOnManualEntry {
            // print("IS ON MANUAL ENTRY")
            showPickerView()
            // print("entry field should begin editing answer: true")
            return true
        } else {
            // print("IS NOT ON MANUAL ENTRY")
            UIApplication.shared.sendAction(#selector(resignFirstResponder), to: nil, from: nil, for: nil)
            showPickerView()
            // print("entry field should begin editing answer: false")
            return false
        }
        // print("entry field should begin editing answer: false")
    }
    
    public func entryFieldShouldReturn(_ view: EntryField) -> Bool {
        // print("entry field should return")
        view.endEditing(true)
        return true
    }
    
    public func entryFieldDidEndEditing(_ view: EntryField) {
        // print("entry field did end editing")
        if isOnManualEntry {
            text = view.text
            donePressed(nil)
        }
    }
}

//MARK:- KEYBOARD LISTENER
extension PickerField {
    /// Detects other fields opening, means focus was lost on us so it closes itself and triggers the endEditing callback.
    @objc private func keyboardWillShow(_ notification: Notification) {
        if isOnManualEntry && entryField.isFirstResponder {return}
        if(isActive){
            donePressed(nil)
        }
    }
}

