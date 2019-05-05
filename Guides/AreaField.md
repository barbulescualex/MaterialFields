# AreaField

---

![AreaFieldDemo](https://github.com/barbulescualex/MaterialFields/blob/master/assets/AreaField/1.gif?raw=true)
![AreaFieldDemoError](https://github.com/barbulescualex/MaterialFields/blob/master/assets/AreaField/2.gif?raw=true)

This is your UITextView with only the text-entry functionality, so a multiline EntryField. Unlike the EntryField this does not support `isMonetary` or `units`.

**[AreaFieldDelegate](https://barbulescualex.github.io/MaterialFields/Protocols/AreaFieldDelegate.html)**

All of the text-entry relevant delegates are here.

**Responder Behaviour**

AreaFields behave the same way that UITextViews behave, `becomeFirstResponder()` will activate the field and `resignFirstResponder()` will deactivate the field.
