// useUpdateAtom
@ocaml.doc("A hook that only returns the update function of an atom. Can be used to access 
writeOnly atoms.

Example:
```
let atom1 = Jotai.Atom.make(1)
let setValue = Jotai.Utils.useUpdateAtom(atom1) 
```
")
@module("jota/utils")
external useUpdateAtom: Atom.writable<'value, _> => Atom.setAtom<'value> = "useUpdateAtom"

// useAtomValue
@ocaml.doc("A hook that only returns the value of an atom. Can be used to access 
readOnly atoms.

Example:
```
let atom1 = Jotai.Atom.make(1)
let value = Jotai.Utils.useAtomValue(atom1) 
```
")
@module("jotai/utils")
external useAtomValue: Atom.readable<'value, _> => 'value = "useAtomValue"

// useResetAtom
@ocaml.doc("Returns a function that can be used to reset a resettable atom.

Example:
```
let atom1 = Jotai.Utils.AtomWithReset(1)  // value: 1
let (_, setValue) = Jotai.Atom.use(atom1)
setValue(2)  // value: 2
let resetValue = Jotai.Utils.useResetAtom(atom1) 
resetValue()  // value back to: 1
```
")
type resetFunc = unit => unit
@module("jotai/utils")
external useResetAtom: Utils_Resettable.t<'value> => resetFunc = "useResetAtom"

// useReducerAtom
@ocaml.doc("Allows to use a reducer function with a (primitive) writable atom.
(Note: Behaves differently with computed atoms)

Example:
```
type actionType = Inc(int) | Dec(int)

let countReducer = (prev, action) => {
  switch action {
  | Inc(num) => prev + num
  | Dec(num) => prev - num
  }
}

let atom1 = Jotai.Atom.make(0)
let (value, dispatch) = Jotai.Utils.useReducerAtom(atom1, countReducer)
Inc(1)->dispatch
```
")
@module("jotai/utils")
external useReducerAtom: (
  Atom.readWrite<'value>,
  Utils_AtomWithReducer.reducer<'value, 'action>,
) => ('value, Utils_AtomWithReducer.dispatch<'action>) = "useReducerAtom"
