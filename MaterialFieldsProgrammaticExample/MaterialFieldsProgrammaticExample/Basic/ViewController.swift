//
//  ViewController.swift
//  MaterialFieldsProgrammaticExample
//
//  Created by Alex Barbulescu on 2019-04-30.
//  Copyright © 2019 alex. All rights reserved.
//

import UIKit
import MaterialFields


class ViewController: UIViewController {
    
    lazy var stackView : UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    lazy var entryField : EntryField = {
        let field = EntryField()
        field.placeholder = "This is an EntryField"
        field.delegate = self
        return field
    }()
    
    lazy var areaField : AreaField = {
        let field = AreaField()
        field.placeholder = "This is an AreaField"
        field.delegate = self
        return field
    }()
    
    lazy var pickerField : PickerField = {
        let field = PickerField()
        field.placeholder = "This is a PickerField"
        field.delegate = self
        field.data = ["one","two","three","four"]
        field.tag = 0
        return field
    }()
    
    lazy var pickerFieldManual : PickerField = {
        let field = PickerField()
        field.placeholder = "This is also a PickerField"
        field.delegate = self
        field.data = ["hee","hee","haa","haa"]
        field.isManualEntryCapable = true
        field.tag = 1
        field.isClearable = true
        return field
    }()
    
    lazy var dateField : DateField = {
        let field = DateField()
        field.placeholder = "This is a DateField"
        field.delegate = self
        field.isClearable = true
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
        
        let textStack = UIStackView()
        textStack.axis = .horizontal
        textStack.distribution = .fillEqually
        textStack.alignment = .top
        textStack.addArrangedSubview(entryField)
        textStack.addArrangedSubview(areaField)
        
        stackView.addArrangedSubview(textStack)
        
        stackView.addArrangedSubview(pickerField)
        stackView.addArrangedSubview(pickerFieldManual)
        stackView.addArrangedSubview(dateField)
        
        textStack.spacing = 5
    }

}

extension ViewController: EntryFieldDelegate {
    
    func entryFieldDidEndEditing(_ view: EntryField) {
        print(view.text as Any, " from entryField")
    }
    
    func entryFieldShouldReturn(_ view: EntryField) -> Bool {
        _ = view.resignFirstResponder()
        return true
    }
}

extension ViewController: PickerFieldDelegate {
    func pickerFieldDidEndEditing(_ view: PickerField) {
        if view.tag == 0 {
            print(view.text as Any, " from pickerField")
        }
        
        if view.tag == 1 {
            print(view.text as Any, " from pickerFieldManual")
        }
    }
    
    func pickerField(_ view: PickerField, didSelectRow row: Int) {
        if view.tag == 0 {
            print("value changed in pickerField: ", view.text as Any)
        }
        if view.tag == 1 {
            print("value changed in pickerFieldManual: ", view.text as Any)
        }
    }
    
    func pickerFieldCleared(_ view: PickerField) {
        if view.tag == 0 {
            print("pickerField cleared:", view.text as Any, " from pickerField")
        }
        
        if view.tag == 1 {
             print("pickerField cleared:", view.text as Any, " from pickerFieldManual")
        }
    }
}

extension ViewController: AreaFieldDelegate{
    func areaFieldDidEndEditing(_ view: AreaField) {
        print(view.text as Any, " from areaField")
    }
    func areaField(_ view: AreaField, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        if text == "\n" {
//            _ = view.resignFirstResponder()
//            return false
//        }
        return true
    }
}

extension ViewController: DateFieldDelegate {
    func dateFieldDidEndEditing(_ view: DateField) {
        print(view.date as Any, " from dateField")
    }
    
    func dateChanged(_ view: DateField){
        print("value changed in dateField: ", view.date as Any)
    }
    
    func dateFieldCleared(_ view: DateField) {
        print("dateField cleared:", view.text as Any, " from dateField")
    }
}
