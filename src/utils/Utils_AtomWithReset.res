@ocaml.doc("Creates an atom that could be reset to its initialValue with `useResetAtom` hook.
To pass this function to a computed atom, the `Resettable.unpack` function has to be used.

Example:
```
let atom1 = Jotai.Utils.AtomWithReset.make(1)
let atom2 = Jotai.Atom.makeComputed(({get}) => atom1->Resettable.unpack->get + 1)  // unpack atom first
```
")
@module("jotai/utils")
external make: 'value => Utils_Resettable.t<'value> = "atomWithReset"
