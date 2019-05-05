# EntryField

---

![EntryFieldDemo](assets/EntryField/1.gif)
![EntryFieldDemoCost](assets/EntryField/2.gif)

This is your UITextField. Most of the UITextField functionality has been forwarded to the EntryField.

**[EntryFieldDelegate](https://barbulescualex.github.io/MaterialFields/Protocols/EntryFieldDelegate.html)**

All of the UITextField delegates are here, just rebranded.

**Extra Features**

* Unit Label : set the `unit` property to a string to populate a unit label anchored on the right hand side.
* Money label : set `isMonetary = true` and a dollar sign is anchored to the left hand side.

Their colors are also overridable using `monetaryColor` or `unitColor`

**Responder Behaviour**

EntryFields behave the same way that UITextFields behave, `becomeFirstResponder()` will activate the field and `resignFirstResponder()` will deactivate the field.