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
        print(entryField.frame)
    }
    
    @IBOutlet weak var entryField: PickerField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        entryField.text = "Hello"
        entryField.placeholder = "Hello World"
        entryField.delegate = self
    }
    
}

extension ViewControllerFrame: EntryFieldDelegate {
    func entryFieldShouldReturn(_ view: EntryField) -> Bool {
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
}
