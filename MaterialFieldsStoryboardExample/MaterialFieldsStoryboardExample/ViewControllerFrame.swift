//
//  ViewControllerFrame.swift
//  MaterialFieldsStoryboardExample
//
//  Created by Alex Barbulescu on 2019-05-03.
//  Copyright © 2019 alex. All rights reserved.
//

import UIKit
import MaterialFields

class ViewControllerFrame: UIViewController {

    @IBAction func frame(_ sender: Any) {
        print(field.frame)
    }
    
    @IBOutlet weak var field: PickerField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        field.text = "Hello"
        field.placeholder = "Hello World"
        field.delegate = self
        field.data = ["one", "two", "three", "four"]
        field.setIndexTo = 0
    }
    
}

extension ViewControllerFrame: EntryFieldDelegate {
    func fieldShouldReturn(_ view: EntryField) -> Bool {
        _ = view.resignFirstResponder()
        view.setError(withText: "WRONG")
        return true
    }
}

extension ViewControllerFrame: AreaFieldDelegate {
    func areaField(_ view: AreaField, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            view.setError(withText: "WRONG")
            _ = view.resignFirstResponder()
        }
        return false
    }
}

extension ViewControllerFrame: PickerFieldDelegate {
    func pickerFieldDidEndEditing(_ view: PickerField) {
        view.setError(withText: "WRONG")
    }
    
    func pickerField(_ view: PickerField, didSelectRow row: Int) {
        view.setError(withText: "WRONG")
    }
}
