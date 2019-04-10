//
//  MissionDateProperty.swift
//  FinTrax
//
//  Created by Alex Barbulescu on 2019-02-01.
//  Copyright © 2019 RCAF Innovation. All rights reserved.
//

import UIKit

@objc protocol DateFieldDelegate : AnyObject {
    @objc optional func dateFieldShouldBeginEditing(_ dateField: DateField) -> Bool
    @objc func dateFieldDidEndEditing(_ dateField: DateField)
    @objc optional func dateFieldCleared(_ dateField: DateField)
}

class DateField: UIView {
    //MARK: UIDATEPICKER VARS
    var date : Date? {
        didSet{
            if let setDate = date {
                datePicker.date = setDate
            } else {
                return
            }
            if let df = dateFormatter {
                fakeField.text = df.string(from: date!)
            } else {
                fakeField.text = defaultFormatter.string(from: date!)
            }
            fakeField.animatePlaceholder(up: true)
        }
    }
    
    var defaultFormatter : DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "MMM dd,yyyy"
        df.timeZone = TimeZone(abbreviation: "GMT")
        return df
    }()
    
    var dateFormatter : DateFormatter?
    
    var datePickerMode : UIDatePicker.Mode? {
        didSet{
            datePicker.datePickerMode = datePickerMode!
        }
    }
    
    var minimumDate : Date? {
        didSet{
            datePicker.minimumDate = minimumDate
        }
    }
    
    var defualtDate : Date? {
        didSet{
            if let setDefault = defualtDate {
                datePicker.date = setDefault
                currentDateInPicker = setDefault
            }
        }
    }
    
    var maximumDate : Date? {
        didSet{
            if let date = maximumDate {
                maxDateSet = true
                datePicker.maximumDate = date
            }
        }
    }
    
    private var maxDateSet = false
    
    var isClearable = false {
        didSet{
            clearButton.isHidden = !isClearable
        }
    }
    
    var placeholder : String? {
        didSet {
            fakeField.placeholder = placeholder! + " (Zulu)"
        }
    }
    
    var currentDateInPicker : Date = Date()
    
    //MARK:- VARS
    private var isActive = false
    weak var delegate : DateFieldDelegate?
    
    //MARK:- VIEW COMPONENTS
    private let verticalStack : UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var fakeField = EntryField()
    
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
    
    public lazy var datePicker : UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.timeZone = TimeZone(abbreviation: "GMT")
        datePicker.locale = Locale(identifier: "en_GB")
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        return datePicker
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    //initWithCode to init view from xib or storyboard
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    //MARK: SETUP FUNCTIONS
    fileprivate func setupView() {
        //fake field
        fakeField.delegate = self
        
        fakeField.addSubview(clearButton)
        clearButton.centerYAnchor.constraint(equalTo: fakeField.centerYAnchor, constant: 5).isActive = true
        clearButton.trailingAnchor.constraint(equalTo: fakeField.trailingAnchor, constant: 0).isActive = true
        clearButton.isHidden = true
        
        fakeField.addSubview(doneButton)
        doneButton.centerYAnchor.constraint(equalTo: fakeField.centerYAnchor, constant: 5).isActive = true
        doneButton.trailingAnchor.constraint(equalTo: fakeField.trailingAnchor, constant: 0).isActive = true
        doneButton.isHidden = true
        
        //keeps it over text
        bringSubviewToFront(doneButton)
        bringSubviewToFront(clearButton)
        
        //vertical stack
        verticalStack.addArrangedSubview(fakeField)
        verticalStack.addArrangedSubview(datePicker)
        datePicker.isHidden = true
        addSubview(verticalStack)
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(keyboardDidShow(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        
        setupLayout()
    }
    
    fileprivate func setupLayout(){
        verticalStack.topAnchor.constraint(equalTo: topAnchor).isActive = true
        verticalStack.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        verticalStack.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        verticalStack.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    @objc fileprivate func dateChanged(_ sender: UIDatePicker){
        currentDateInPicker = sender.date
    }
    
    //MARK: FUNCTIONS
    func showDatePicker(){
        doneButton.isHidden = false
        clearButton.isHidden = true
        
        fakeField.isEditing(showHighlight: true)
        
        if !maxDateSet {
            datePicker.maximumDate = Date()
        }
        isActive = true
        if let lastPickedDate = date {
            datePicker.setDate(lastPickedDate, animated: false)
        }
        datePicker.isHidden = false
    }

    
    @objc func donePressed(_ sender: UIButton?){
        date = currentDateInPicker
        fakeField.isEditing(showHighlight: false)
        
        datePicker.isHidden = true
        delegate?.dateFieldDidEndEditing(self)
        isActive = false
        
        doneButton.isHidden = true
        clearButton.isHidden = !isClearable
    }
    
    
    @objc func clearPressed(_ sender: UIButton){
        fakeField.text = nil
        delegate?.dateFieldCleared?(self)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK:- ENTRYFIELD DELEGATE
extension DateField : EntryFieldDelegate {
    func entryFieldShouldBeginEditing(_ view: EntryField) -> Bool {
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

