//
//  MissionDateProperty.swift
//  MaterialFields
//
//  Created by Alex Barbulescu on 2019-02-01.
//  Copyright © 2019 Alex Barbulescu. All rights reserved.
//

import UIKit

@objc public protocol PickerFieldDelegate : AnyObject {
    @objc optional func pickerFieldShouldBeginEditing(_ view: PickerField) -> Bool
    
    @objc func pickerFieldDidEndEditing(_ view: PickerField)
    
    @objc optional func pickerFieldCleared(_ view: PickerField)
    
    @objc optional func pickerField(_ view: PickerField, didSelectRow row: Int)
}

public class PickerField: Field {
    //MARK:- UIPICKER VARS
    public var isClearable = false {
        didSet{
            clearButton.isHidden = !isClearable
        }
    }
    
    // picker data
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
    
    // optional placeholder value for the text field
    public var placeholder : String? {
        didSet {
            entryField.placeholder = placeholder!
        }
    }
    
    // setter for the entry field text and getter for the value it holds
    override public var text: String? {
        didSet{
            entryField.text = text
        }
    }
    
    public var setIndexTo : Int = 0 {
        didSet{
            if setIndexTo < 0 {
                setIndexTo = 0
            }
            pickerView.selectRow(setIndexTo, inComponent: 0, animated: true)
            indexSelected = setIndexTo
            indexSet = true
        }
    }
    
    private var indexSet = false {
        didSet{
            if data.indices.contains(setIndexTo){
                if !isOnManualEntry{
                    entryField.text = data[setIndexTo]
                }
            }
        }
    }
    
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
    
    public var keyboardTypeForManualEntry : UIKeyboardType = .asciiCapable {
        didSet{
            entryField.keyboardType = keyboardTypeForManualEntry
        }
    }
    
    public var autocapitalizationTypeForManualEntry : UITextAutocapitalizationType = .none {
        didSet{
            entryField.autocapitalizationType = autocapitalizationTypeForManualEntry
        }
    }
    
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
    
    private var manualEntrySet = false
    private var manualEntryIndex : Int?
    
    private(set) var indexSelected : Int = 0 {
        didSet{
            if let manualEntryIndex = manualEntryIndex, indexSelected == manualEntryIndex {
                isOnManualEntry = true
            } else {
                isOnManualEntry = false
            }
        }
    }
    
    private var isOnManualEntry = false {
        didSet{
            if !isOnManualEntry {
                _ = entryField.resignFirstResponder()
            }
        }
    }
    
    public func setIndexToManual(){
        if isManualEntryCapable && manualEntrySet {
            guard let index = manualEntryIndex else {return}
            setIndexTo = index
        }
    }
    
    //COLORS
    //entryfield
    public var borderColor: UIColor = UIColor.lightGray {
        didSet{
            entryField.borderColor = borderColor
        }
    }
    
    public var borderHighlightColor: UIColor = UIColor.babyBlue {
        didSet{ //NEEDS WORK
            entryField.borderHighlightColor = borderHighlightColor
        }
    }
    
    public var borderErrorColor: UIColor = UIColor.red {
        didSet{
            entryField.borderErrorColor = borderErrorColor
        }
    }
    
    public var textColor: UIColor = UIColor.black {
        didSet{
            entryField.textColor = textColor
        }
    }
    
    public var errorTextColor: UIColor = UIColor.red {
        didSet{
            entryField.errorTextColor = errorTextColor
        }
    }
    
    public var placeholderDownColor: UIColor = UIColor.gray {
        didSet{
            entryField.placeholderDownColor = placeholderDownColor
        }
    }
    
    public var placeholderUpColor: UIColor = UIColor.black {
        didSet{
            entryField.placeholderUpColor = placeholderUpColor
        }
    }
    
    public var cursorColor: UIColor = UIColor.black.withAlphaComponent(0.5) {
        didSet{
            entryField.cursorColor = cursorColor
        }
    }
    
    //buttons
    public var clearButtonColor: UIColor = UIColor.babyBlue{
        didSet{
            clearButton.backgroundColor = clearButtonColor
        }
    }
    
    public var doneButtonColor: UIColor = UIColor.babyBlue{
        didSet{
            doneButton.backgroundColor = doneButtonColor
        }
    }
    
    //MARK: VARS
    weak public var delegate : PickerFieldDelegate?
    private var isActive = false
    
    //MARK: VIEW COMPONENTS
    // vertical stack for EntryField and UIPickerView
    let verticalStack : UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // entry field for text / label
    var entryField = EntryField()
    
    private lazy var clearButton : UIButton = {
        let button = UIButton()
        let attributes = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : UIColor.white]
        button.backgroundColor = UIColor.babyBlue
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
        button.backgroundColor = UIColor.babyBlue
        button.setAttributedTitle(NSAttributedString(string: "done", attributes: attributes), for: .normal)
        button.addTarget(self, action: #selector(donePressed(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.contentEdgeInsets = UIEdgeInsets(top: 3.5, left: 5, bottom: 3.5, right: 5)
        return button
    }()
    
    //pickerView
    public lazy var pickerView : UIPickerView = {
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
        setupView()
    }
    
    //initWithCode to init view from xib or storyboard
    required init?(coder aDecoder: NSCoder) {
        self.data = []
        super.init(coder: aDecoder)
        setupView()
    }
    
    //MARK: SETUP FUNCTIONS
    private func setupView() {
        // entry field
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
    @objc func donePressed(_ sender: UIButton?){
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
    
    private func showPickerView(){
        if isActive {return}
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
    
    override public func setError(withText text: String?) {
        if !isActive || !isOnManualEntry { return }
        entryField.setError(withText: text)
    }
    
    @objc func clearPressed(_ sender: UIButton){
        entryField.text = nil
        delegate?.pickerFieldCleared?(self)
    }
    
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
        delegate?.pickerField?(self, didSelectRow: row)
        self.indexSelected = row
        if isOnManualEntry {
            self.entryField.text = nil
            _ = entryField.becomeFirstResponder()
        } else {
            self.entryField.text = data[row]
        }
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
    //detect other field opening, means focus was lost on us so close the pickerView
    @objc func keyboardWillShow(_ notification: Notification) {
        if isOnManualEntry && entryField.isFirstResponder {return}
        if(isActive){
            donePressed(nil)
        }
    }
}

