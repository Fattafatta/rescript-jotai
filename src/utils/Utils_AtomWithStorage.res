// TODO Add support for additional storage options
@ocaml.doc("AtomWithStorage creates an atom with a value persisted in `localStorage`
Currently only `localStorage` is supported.

Example:
```
let atom1 = Jotai.Utils.AtomWithStorage.make('storageKey', 1)
```
")
@module("jotai/utils")
external make: (string, 'value) => Atom.readWrite<'value> = "atomWithStorage"
