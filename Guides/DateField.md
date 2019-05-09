# DateField

---

![DateFieldDemo](https://github.com/barbulescualex/MaterialFields/blob/master/assets/DateField/1.gif?raw=true)
![DateFieldDemo](https://github.com/barbulescualex/MaterialFields/blob/master/assets/DateField/2.gif?raw=true)

![DateFieldDemo](https://github.com/barbulescualex/MaterialFields/blob/master/assets/DateField/3.gif?raw=true)

This is your UIDatePicker. You can do all the things you can do with the UIDatePicker you're used to, the property names are the same.

**[DateFieldDelegate](https://barbulescualex.github.io/MaterialFields/Protocols/DateFieldDelegate.html)**

This mirrors the PickerField delegate.

You have:

* shouldBeginEditing : wether it should open or not

* didEndEditing: user closed the field by tapping on the done button or keyboard came up (see Keyboard Behaviour)

* cleared : user tapped the clear button (only if `isClearable = true`)

* dateChanged : user selected a different date

**Responder Behaviour**

* `becomeFirstResponder()` will activate and open up the picker
* `closeFirstResponder()` will deactivate and close the picker

**Keyboard Behaviour**

DateFields register for keyboardDidShow notifications. They will close themselves and trigger their didEndEditing delegate upon the keyboard coming up.