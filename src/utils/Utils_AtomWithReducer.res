type reducer<'value, 'action> = ('value, 'action) => 'value
type dispatch<'action> = 'action => unit
// type withReducer<'value> = Atom.readWrite<'value>

@ocaml.doc("Creates an atom that uses a reducer to update its value.

Example:
```
type actionType = Inc(int) | Dec(int)

let countReducer = (prev, action) => {
  switch action {
  | Inc(num) => prev + num
  | Dec(num) => prev - num
  }
}

let atom1 = Jotai.Utils.AtomWithReducer.make(0, countReducer)

let (value, dispatch) = Jotai.Atom.use(atom1)
Inc(1)->dispatch
```
")
@module("jotai/utils")
external make: ('value, reducer<'value, 'action>) => Atom.readWrite<'value> = "atomWithReducer"
