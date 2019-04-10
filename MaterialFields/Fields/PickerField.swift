//
//  MissionDateProperty.swift
//  FinTrax
//
//  Created by Alex Barbulescu on 2019-02-01.
//  Copyright © 2019 RCAF Innovation. All rights reserved.
//

import UIKit

@objc protocol PickerFieldDelegate : AnyObject {
    @objc optional func pickerFieldShouldBeginEditing(_ pickerView: PickerField) -> Bool
    @objc func pickerFieldDidEndEditing(_ pickerView: PickerField)
    @objc optional func pickerFieldCleared(_ pickerView: PickerField)
}

class PickerField: UIView{
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
                
            }
            if isManualEntryCapable && manualEntrySet {
                guard let removeIndex = manualEntryIndex else {return}
                data.remove(at: removeIndex)
                data.append(manualEntryOptionName)
                manualEntryIndex = data.count - 1
            }
            pickerView.reloadAllComponents()
        }
    }
    
    // optional placeholder value for the text field
    public var placeholder : String? {
        didSet {
            entryField.placeholder = placeholder!
        }
    }
    
    // setter for the entry field text
    public var text: String? {
        didSet{
            entryField.text = text
            value = text
        }
    }
    
    public var setIndexTo : Int = 0 {
        didSet{
            pickerView.selectRow(setIndexTo, inComponent: 0, animated: true)
            indexSelected = setIndexTo
        }
    }
    
    public var isManualEntryCapable : Bool = false {
        didSet{
            if isManualEntryCapable {
                manualEntrySet = true
                data.append(manualEntryOptionName)
                manualEntryIndex = data.count - 1
                pickerView.reloadAllComponents()
            } else {
                manualEntrySet = false
                guard let index = manualEntryIndex else {return}
                data.remove(at: index)
                manualEntryIndex = nil
                isOnManualEntry = false
                pickerView.reloadAllComponents()
            }
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
    
    //getter only
    private(set) var value : String? {
        didSet{
            entryField.text = value
        }
    }
    
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
    
    //MARK: VARS
    weak var delegate : PickerFieldDelegate?
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
    public var pickerView : UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.showsSelectionIndicator = true
        return pickerView
    }()
    
    //MARK:- INIT
    override init(frame: CGRect) {
        self.data = []
        super.init(frame: frame)
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
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.reloadAllComponents()
        
        // vertical stack
        verticalStack.addArrangedSubview(entryField)
        verticalStack.addArrangedSubview(pickerView)
        
        // default visibility
        entryField.isHidden = false
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
            value = data[indexSelected]
        }
        entryField.endEditing(true)
        delegate?.pickerFieldDidEndEditing(self)
        isActive = false
        entryField.isEditing(showHighlight: false)
        doneButton.isHidden = true
        clearButton.isHidden = !isClearable
    }
    
    func showPickerView(){
        doneButton.isHidden = false
        clearButton.isHidden = true
        isActive = true
        pickerView.isHidden = false
        entryField.isEditing(showHighlight: true)
    }
    
    @objc func clearPressed(_ sender: UIButton){
        entryField.text = nil
        value = nil
        delegate?.pickerFieldCleared?(self)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK:- UIPICKERDELEGATE
extension PickerField: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return data.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return data[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.entryField.animatePlaceholder(up: true)
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
    func entryFieldShouldBeginEditing(_ view: EntryField) -> Bool {
        if let shouldBegin = delegate?.pickerFieldShouldBeginEditing?(self) {
            if !shouldBegin {
                return false
            }
        }
        if isOnManualEntry {
            if !isActive {
                showPickerView()
            }
            return true
        } else {
            UIApplication.shared.sendAction(#selector(resignFirstResponder), to: nil, from: nil, for: nil)
            showPickerView()
        }
        return false
    }
    
    func entryFieldShouldReturn(_ view: EntryField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    func entryFieldDidEndEditing(_ view: EntryField) {
        if isOnManualEntry {
            value = view.text
            donePressed(nil)
            delegate?.pickerFieldDidEndEditing(self)
        }
    }
}

//MARK:- KEYBOARD LISTENER
extension PickerField {
    //detect other field opening, means focus was lost on us so close the pickerView
    @objc func keyboardWillShow(_ notification: Notification) {
        if isOnManualEntry && entryField.isFirstResponder {return}
        pickerView.isHidden = true
        if(isActive){
            donePressed(nil)
        }
    }
}

