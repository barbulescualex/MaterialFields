//
//  Person.swift
//  MaterialFieldsProgrammaticExample
//
//  Created by Alex Barbulescu on 2019-06-01.
//  Copyright © 2019 alex. All rights reserved.
//

import Foundation
import MaterialFields

enum PersonKeys: String, CaseIterable {
    case name
    case cost
    case age
    case birthDate
    case console
    case notes
}

class Person {
    //entryField
    var name : String?
    var cost : NSDecimalNumber?
    var age : Int?
    
    //dateField
    var birthDate : Date?
    
    //pickerField
    var console : String?
    
    //areaField
    var personalNotes : String?
    
    init(){
    }
}

extension Person {
    //updates model
    func validateAge(field: Field, key: String){
        let value = field.text
        
        if value.isNotComplete() { return }
        
        if let age = Int(value!) {
            if age < 10 {
                field.setError(withText: "too young!")
            }
            if age > 100 {
                field.setError(withText: "too old!")
            }
            self.age = age
        } else {
            field.setError(withText: "Listen here buddy, no more funny games")
        }
    }
    
    //Validates, but lets the controller handle updating the model and viewstate
    func validateName(field: Field, key: String) -> Bool? {
        guard let value = field.text, value != "" else {return nil}
        
        return PersonData.names.contains(value)
    }
    
    //Updates model
    func validateCost(field: Field, key: String){
        var value = field.text
        if value.isNotComplete() {
            value = "0"
        }
        
        let decimal = NSDecimalNumber(string: value!)
        if decimal.isEqual(to: NSDecimalNumber.notANumber){
            field.setError(withText: "please enter a valid cost")
            return
        }
        self.cost = decimal
    }
    
    //Updates model
    func validateConsole(field: Field, key: String){
        guard let value = field.text, value != "" else {return}
        
        if value == "PC" {
            self.console = value
        } else {
            field.setError(withText: "PC MASTER RACE")
        }
    }
}

class PersonData {
    static let names = ["John","Jerry","Mary"]
    static let consoles = ["PS4","Xbox One","Switch"]
}
