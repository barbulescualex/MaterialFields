# Validation Layers

---

Since all the fields conform to the Field class, validation layers tied directly to the Fields has never been easier!


Lets define 3 fields, an EntryField, an AreaField, and a PickerField

``` swift
let entryField = EntryField()
let areaField = AreaField()
let pickerField = PickerField()
```

Lets also define a CaseIterable enum:

``` swift
extension CaseIterable where AllCases.Element: Equatable {
    static func make(index: Int) -> Self? { //get the key from the case index
        let a = Self.allCases
        if (index > a.count - 1) { return nil } //out of range
        return a[a.index(a.startIndex, offsetBy: index)]
    }
    
    func index() -> Int { //get the index from the case
        let a = Self.allCases
        return a.distance(from: a.startIndex, to: a.firstIndex(of: self)!)
    }
}

enum FieldKeys : String, CaseIterable {
  case entry
  case area
  case picker
}

```

With our CaseIterable enum we can use the validation keys as tags for the fields!

``` swift
entryField.tag = FieldKeys.entry.index()
areaField.tag = FieldKeys.area.index()
pickerField.tag = FieldKeys.picker.index()

```

Lets say we need to validate a generic string (with the regex set in our core data model) before commiting changes to our model using an extension on NSManagedObject.

``` swift
extension NSManagedObject {
  func validateString(view: Field, key: String){
      var value = view.text as AnyObject?
       do {
            try self.validateValue(&(value), forKey: key)
       } catch {
            view.setError(withText: "please try again")
            print(error)
            return
        }
        self.setValue(value, forKey: key)
  }
}
```

Now on any of the fields' didEndEditing delegate methods we only need to 2 lines to validate our entry.

``` swift
//EntryFieldDelegates
func entryFieldDidEndEditing(_ view: EntryField){
  //the key reconstructed from our enum used for the field tags
  gaurd let key = FieldKeys.make(index: view.tag) else {return}
  ourNSManagedObject.validateString(view,key.rawValue)
}

//AreaFieldDelegates
func areaFieldDidEndEditing(_ view: AreaField){
  //the key reconstructed from our enum used for the field tags
  gaurd let key = FieldKeys.make(index: view.tag) else {return}
  ourNSManagedObject.validateString(view,key.rawValue)
}

//PickerFieldDelegates
func pickerFieldDidEndEditing(_ view: PickerField){
  //the key reconstructed from our enum used for the field tags
  gaurd let key = FieldKeys.make(index: view.tag) else {return}
  ourNSManagedObject.validateString(view,key.rawValue)
}
```

We now have a validation layer capable of both data model validation and UI feedback!
