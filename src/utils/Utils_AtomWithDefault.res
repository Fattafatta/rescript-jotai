@ocaml.doc("This is a function to create a resettable primitive atom. Its default
value can be specified with a read function instead of a static initial value.
To pass this function to a computed atom, the `Resettable.unpack` function has to be used.

Example:
```
let atom1 = Jotai.Atom.make(1)
let atom2 = Jotai.Utils.AtomWithDefault.make(({get}) => get(atom1) + 1)
let atom3 = Jotai.Atom.makeComputed(({get}) => atom2->Resettable.unpack->get + 1)  // unpack atom first
```
")
@module("../wrapper")
external make: Atom.getValue<'value> => Utils_Resettable.t<'value> = "atomWithDefaultWrapped"
external makeAsync: Atom.getValueAsync<'value> => Utils_Resettable.t<'value> =
  "atomWithDefaultWrapped"
