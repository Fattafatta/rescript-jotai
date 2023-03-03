// useUpdateAtom
@deprecated("[DEPRECATED]: use `useSetAtom` from `jotai` instead.")
@ocaml.doc("A hook that returns only the update function of an atom. Can be used to access writeOnly atoms.

```rescript
let atom = Jotai.Atom.make(1)
let setValue = Jotai.Utils.useUpdateAtom(atom) 
setValue(prev => prev + 1)
```
")
@module("jotai/utils")
external useUpdateAtom: Atom.t<'value, Atom.Actions.t<'action>, [> Atom.Tags.w]> => 'action =
  "useUpdateAtom"

// useAtomValue
@deprecated("[DEPRECATED]: use `useAtomValue` from `jotai` instead.")
@ocaml.doc("A hook that returns only the value of an atom. Can be used to access 
readOnly atoms.

```rescript
let atom = Jotai.Atom.make(1)
let value = Jotai.Utils.useAtomValue(atom) 
```
")
@module("jotai/utils")
external useAtomValue: Atom.t<'value, _, [> Atom.Tags.r]> => 'value = "useAtomValue"

// useResetAtom
@ocaml.doc("Returns a function that can be used to reset a resettable atom.

```rescript
let atom = Jotai.Utils.AtomWithReset(1)  // value: 1
let (_, setValue) = Jotai.Atom.use(atom)
setValue(2)  // value: 2
let resetValue = Jotai.Utils.useResetAtom(atom) 
resetValue()  // value back to: 1
```
")
type reset = unit => unit
@module("jotai/utils")
external useResetAtom: Atom.t<'value, _, [> Atom.Tags.re]> => reset = "useResetAtom"

// useReducerAtom
@ocaml.doc("Allows to use a reducer function with a primitive atom.

```rescript
type actionType = Inc(int) | Dec(int)
let countReducer = (prev, action) => {
  switch action {
  | Inc(num) => prev + num
  | Dec(num) => prev - num
  }
}
let atom = Jotai.Atom.make(0)
let (value, dispatch) = Jotai.Utils.useReducerAtom(atom, countReducer)
Inc(1)->dispatch
```
")
@module("jotai/utils")
external useReducerAtom: (
  Atom.t<'value, _, [> Atom.Tags.p]>,
  Utils_AtomWithReducer.reducer<'value, 'action>,
) => ('value, Utils_AtomWithReducer.dispatch<'action>) = "useReducerAtom"
