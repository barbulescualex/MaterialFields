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
        field.becomeFirstResponder()
    }
    
    @IBOutlet weak var field: EntryField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        field.placeholder = "EntryField"
        field.delegate = self
    }
    
}

extension ViewControllerFrame: EntryFieldDelegate {
    func entryFieldShouldReturn(_ view: EntryField) -> Bool {
        print("Should return")
        _ = view.resignFirstResponder()
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
