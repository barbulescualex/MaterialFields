# Field

---

First we define a Field. This is the wrapper class that all the fields conform to. This allows all of them to share implemenation and functionality and also leads to an easier validation layer

**2 Types Of Fields**

1. Text-entry fields. This comprises of [EntryField](https://barbulescualex.github.io/MaterialFields/Classes/EntryField.html) and [AreaField](https://barbulescualex.github.io/MaterialFields/Classes/AreaField.html).

2. Picker type fields. This comprises of [PickerField](https://barbulescualex.github.io/MaterialFields/Classes/PickerField.html) and [DateField](https://barbulescualex.github.io/MaterialFields/Classes/DateField.html)

They all look the exact same in their normal state but each offer their own unique functionality in different states. Picker type fields hold entry fields with pickers that drop down below them. They have done buttons to close themselves and optional clear buttons (set by `isClearable = true`).

**States**

A Field has **3 states**: 

* Not active : `isActive = false`
* Active, highlight visible : `isActive = true`
* Error : `hasError = true`

All the state logic and UI is handled internally. You can set the error state using [setError(withText:)](https://barbulescualex.github.io/MaterialFields/Classes/Field.html#/s:14MaterialFields5FieldC8setError8withTextySSSg_tF) and also remove it manually (the fields handle it on their own automatically, see specific field for details) using [removeErrorUI()](https://barbulescualex.github.io/MaterialFields/Classes/Field.html#/s:14MaterialFields5FieldC13removeErrorUIyyF)

**Values**

They return **2 types of values**:

* String accessed by `.text` if it is an EntryField, AreaField or PickerField and,
* Date accessed by `.date` if it is DateField

**Sizing**

Fields rely on their [intrinsicContentSize](https://developer.apple.com/documentation/uikit/uiview/1622600-intrinsiccontentsize). This is becuase they can change in height depending on if they open a picker or have text in their error state. The easiest way to implement them is by throwing them inside UIStackViews and letting auto-layout handle everything around them. It can be more work if you want to set a height constraint (through auto-layout or a frame) but below are the heights for each field and their given state.

| Field Type | Normal  | Error | Picker Open | Picker Open + Error |
----------|-----------------|----------|-----------|---------|
EntryField | 43.5 | 63.0 | N/A | N/A |
AreaField | 43.5+ | 63.0+ | N/A | N/A |
PickerField | 43.5 | 63.0 | 269.5 | 289 |
DateField | 43.5 | 63.0 | 269.5 | 289 |

**Colors**

Since all fields look the same they all have the exact same color properties (with small differences given the features).