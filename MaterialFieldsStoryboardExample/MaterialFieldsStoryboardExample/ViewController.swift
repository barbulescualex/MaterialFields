//
//  ViewController.swift
//  MaterialFieldsStoryboardExample
//
//  Created by Alex Barbulescu on 2019-05-01.
//  Copyright © 2019 alex. All rights reserved.
//

import UIKit
import MaterialFields

class ViewController: UIViewController {
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var textStack: UIStackView!
    @IBOutlet weak var entryField: EntryField!
    @IBOutlet weak var areaField: AreaField!
    
    @IBOutlet weak var pickerStack: UIStackView!
    @IBOutlet weak var pickerField: PickerField!
    @IBOutlet weak var pickerFieldManual: PickerField!
    
    
    @IBOutlet weak var dateField: DateField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStackViews()
        setupFields()
    }
    
    fileprivate func setupStackViews(){
        stackView.distribution = .fill
        
        textStack.spacing = 5
        textStack.alignment = .top
        textStack.distribution = .fillEqually
        
        pickerStack.spacing = 5
        pickerStack.alignment = .top
        pickerStack.distribution = .fillEqually
    }
    
    fileprivate func setupFields(){
        entryField.placeholder = "This is an EntryField"
        entryField.delegate = self
        
        areaField.placeholder = "This is an AreaField"
        areaField.delegate = self
        
        pickerField.placeholder = "This is a PickerField"
        pickerField.delegate = self
        pickerField.data = ["hee","hee","haa","haa"]
        pickerField.tag = 0
        
        pickerFieldManual.placeholder = "This is also a PickerField"
        pickerFieldManual.delegate = self
        pickerFieldManual.data = ["hee","hee","haa","haa"]
        pickerFieldManual.isManualEntryCapable = true
        pickerFieldManual.tag = 1
    
        
        dateField.placeholder = "This is a DateField"
        dateField.delegate = self
        dateField.isClearable = true
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
        print(view.text as Any, " from areaField!")
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
