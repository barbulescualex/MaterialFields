# PickerField

---

![PickerFieldDemo](assets/PickerField/1.gif)
![PickerFieldDemo](assets/PickerField/2.gif)

![PickerFieldDemo](assets/PickerField/3.gif)
![PickerFieldDemo](assets/PickerField/4.gif)

This is your UIPickerView which only supports 1 column. Most of the setup work has been extracted away, leaving little implementation logic needed. All you need to do is set its `data` array to your string array and the rest is handled for you.
The PickerField holds an EntryField that is used to display the contents of the picker.

**[PickerFieldDelegate](https://barbulescualex.github.io/MaterialFields/Protocols/PickerFieldDelegate.html)**

This will be a little different than you're used to as you no longer need to implement the data source protocol.

You have:

* shouldBeginEditing : wether it should open or not

* didEndEditing: user closed the field by tapping on the done button

* cleared : user tapped the clear button (only if `isClearable = true`)

* selectedRowForIndexPath : user selected a different value in the picker


**Extra Features**

* `isManualEntryCapable` this appends a "Manual Entry" option to the end of your data source which brings up the keyboard if selected and activates the EntryField embedded inside the PickerField. The manual entry row label is overridable using `manualEntryOptionName`.

You can observe the current index using `indexSelected` set an index using `setIndexTo` and set the index to manual entry using `setIndexToManual()`.

**Responder Behaviour**

* `becomeFirstResponder()` will activate and open up the picker / EntryField if it's on manual entry
* `closeFirstResponder()` will deactivate and close the picker / EntryField if it's on manual entry