// useUpdateAtom
let useUpdateAtom = failwith("Moved to core. Use `Atom.useSetAtom` instead")

// useAtomValue
let useAtomValue = failwith("Moved to core. Use `Atom.useAtomValue` instead")

// useResetAtom
/** Returns a function that can be used to reset a resettable atom.

```rescript
let atom = Jotai.Utils.AtomWithReset(1)  // value: 1
let (_, setValue) = Jotai.Atom.use(atom)
setValue(2)  // value: 2
let resetValue = Jotai.Utils.useResetAtom(atom) 
resetValue()  // value back to: 1
```
*/
type reset = unit => unit
@module("jotai/utils")
external useResetAtom: Atom.t<'value, _, [> Atom.Tags.re]> => reset = "useResetAtom"

// useReducerAtom
/** Allows to use a reducer function with a primitive atom.

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
*/
@module("jotai/utils")
external useReducerAtom: (
  Atom.t<'value, _, [> Atom.Tags.p]>,
  Utils_AtomWithReducer.reducer<'value, 'action>,
) => ('value, Utils_AtomWithReducer.dispatch<'action>) = "useReducerAtom"

/** Hook to refresh an AtomWithRefresh. 
(This is the equivalent of calling the set function without arguments in jotai)

```rescript
let atom1 = Jotai.Utils.AtomWithRefresh.make(_ => 1)
let (value, refresh) = Jotai.Utils.useRefreshAtom(atom1) 
refresh()
```
*/
@module("jotai")
external useRefreshAtom: Atom.t<'value, _, [> Atom.Tags.r | Atom.Tags.fr]> => (
  'value,
  unit => unit,
) = "useAtom"
