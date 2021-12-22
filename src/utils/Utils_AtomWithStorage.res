// TODO Add support for additional storage options
@ocaml.doc("Creates an atom with a value persisted in `localStorage`
Currently only `localStorage` is supported.

```rescript
let atom1 = Jotai.Utils.AtomWithStorage.make('storageKey', 1)
```
")
@module("jotai/utils")
external make: (
  string,
  'value,
) => Atom.t<'value, Atom.Actions.set<'value>, [Atom.Tags.r | Atom.Tags.w | Atom.Tags.p]> =
  "atomWithStorage"
