//
//  ErrorViewController.swift
//  MaterialFieldsProgrammaticExample
//
//  Created by Alex Barbulescu on 2019-06-01.
//  Copyright © 2019 alex. All rights reserved.
//

import UIKit
import MaterialFields

class ErrorViewController: UIViewController {
    var person = Person()
    
    lazy var stackView : UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    //EntryFields
    lazy var nameField : EntryField = {
        let field = EntryField()
        field.placeholder = "Name"
        field.delegate = self
        field.tag = PersonKeys.name.index()
        return field
    }()
    
    lazy var costField : EntryField = {
        let field = EntryField()
        field.placeholder = "Life Value"
        field.delegate = self
        field.tag = PersonKeys.cost.index()
        field.isMonetary = true
        field.unit = "CAD"
        return field
    }()
    
    lazy var ageField : EntryField = {
        let field = EntryField()
        field.placeholder = "Your Age"
        field.delegate = self
        field.tag = PersonKeys.age.index()
        return field
    }()
    
    //DateFields
    lazy var birthDate : DateField = {
        let field = DateField()
        field.placeholder = "Date Of Birth"
        field.delegate = self
        field.isClearable = true
        field.tag = PersonKeys.birthDate.index()
        return field
    }()
    
    //PickerFields
    lazy var consoleField : PickerField = {
        let field = PickerField()
        field.placeholder = "Console"
        field.delegate = self
        field.data = PersonData.consoles
        field.tag = PersonKeys.console.index()
        field.isManualEntryCapable = true
        field.isClearable = true
        return field
    }()
    
    //AreaFields
    lazy var notes : AreaField = {
        let field = AreaField()
        field.placeholder = "Notes"
        field.delegate = self
        field.tag = PersonKeys.notes.index()
        return field
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupFields()
    }
    
    fileprivate func setupFields(){
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 5),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -5),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
        ])
        stackView.spacing = 5
    
        stackView.addArrangedSubview(nameField)
        stackView.addArrangedSubview(costField)
        stackView.addArrangedSubview(ageField)
        stackView.addArrangedSubview(birthDate)
        stackView.addArrangedSubview(consoleField)
        stackView.addArrangedSubview(notes)
    }
    
}

extension ErrorViewController: EntryFieldDelegate {
    
    func entryFieldDidEndEditing(_ view: EntryField) {
        guard let key = PersonKeys.make(index: view.tag) else {return}//case
        switch key {
        case .name:
            if let valid = person.validateName(field: view, key: key.rawValue) {
                if valid {
                    person.name = view.text
                } else {
                    view.setError(withText: "That's not a real name lol")
                }
            } else { //value was nil or empty, decide what to do with it
                person.name = nil
            }
        case .age:
            person.validateAge(field: view, key: key.rawValue)
        case .cost:
            person.validateCost(field: view, key: key.rawValue)
        default:
            print("defaulted in entryFieldDidEndEditing")
        }
    }
    
    func entryFieldShouldReturn(_ view: EntryField) -> Bool {
        _ = view.resignFirstResponder()
        return true
    }
}

extension ErrorViewController: PickerFieldDelegate {
    func pickerFieldDidEndEditing(_ view: PickerField) {
        guard let key = PersonKeys.make(index: view.tag) else {return}
        if (key == .console) {
            person.validateConsole(field: view, key: key.rawValue)
        }
    }
    
    func pickerFieldCleared(_ view: PickerField) {
        let key = PersonKeys.make(index: view.tag)
        if (key == .console) {
            person.console = nil
        }
    }
}

extension ErrorViewController: AreaFieldDelegate{
    func areaFieldDidEndEditing(_ view: AreaField) {
        person.personalNotes = view.text
    }
    func areaField(_ view: AreaField, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            _ = view.resignFirstResponder()
            return false
        }
        return true
    }
}

extension ErrorViewController: DateFieldDelegate {
    func dateFieldDidEndEditing(_ view: DateField) {
        person.birthDate = view.date
    }
    
    func dateFieldCleared(_ view: DateField) {
        person.birthDate = nil
    }
}
