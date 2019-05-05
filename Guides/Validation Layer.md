# Validation Layers

Since all the fields conform to the Field class, validation layers tied directly to the Fields has never been easier!


Lets define 3 fields, an EntryField, an AreaField, and a PickerField

```
let entryField = EntryField()
let areaField = AreaField()
let pickerField = PickerField()
```

Lets also define a CaseIterable enum:

```
extension CaseIterable where AllCases.Element: Equatable {
    static func make(index: Int) -> Self { //get the key from the case index
        let a = Self.allCases
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

```
entryField.tag = FieldKeys.entry.index()
areaField.tag = FieldKeys.area.index()
pickerField.tag = FieldKeys.picker.index()

```

Lets say we need to validate a generic string before commiting changes to our Core Data model using an extension on NSManagedObject.

```
extension NSManagedObject {
  func validateString(view: Field, key: String?){
      var value = view.text as AnyObject?
       do {
            try self.validateValue(&(value), forKey: key)
       } catch {
            view.setError(errorText: "please try again")
            print(error)
            return
        }
        self.setValue(value, forKey: key)
  }
```

Now on any of the fields didEndEditing delegate methods we only need to 2 lines to validate our entry.

```
//EntryFieldDelegates
func entryFieldDidEndEditing(_ view: EntryField){
  let key = FieldKeys.make(index: view.tag) //the key reconstructed from our enum used for the field tags
  ourNSManagedObject.validateString(view,key)
}

//AreaFieldDelegates
func areaFieldDidEndEditing(_ view: AreaField){
  let key = FieldKeys.make(index: view.tag) //the key reconstructed from our enum used for the field tags
  ourNSManagedObject.validateString(view,key)
}

//PickerFieldDelegates
func pickerFieldDidEndEditing(_ view: PickerField){
  let key = FieldKeys.make(index: view.tag) //the key reconstructed from our enum used for the field tags
  ourNSManagedObject.validateString(view,key)
}
```

We now have tightly coupled our Fields (in a good way!) with our validation layer for both our data model and UI feedback!