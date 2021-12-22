type reducer<'value, 'action> = ('value, 'action) => 'value
type dispatch<'action> = 'action => unit

@ocaml.doc("Creates an atom that uses a reducer to update its value.

```rescript
type actionType = Inc(int) | Dec(int)
let countReducer = (prev, action) => {
  switch action {
  | Inc(num) => prev + num
  | Dec(num) => prev - num
  }
}
let atom = Utils.AtomWithReducer.make(0, countReducer)
let (value, dispatch) = Atom.use(atom)
Inc(1)->dispatch
```
")
@module("jotai/utils")
external make: (
  'value,
  reducer<'value, 'action>,
) => Atom.t<'value, Atom.Actions.dispatch<'action>, [Atom.Tags.r | Atom.Tags.w]> = "atomWithReducer"
