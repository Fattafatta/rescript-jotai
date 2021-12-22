@ocaml.doc("Creates an atom that can be resetted to its initialValue with the `useResetAtom` hook.

```rescript
let atom = Jotai.Utils.AtomWithReset.make(1)
// ... change value ...
let reset = Jotai.Utils.useResetAtom(atom)
reset()
```
")
@module("jotai/utils")
external make: 'value => Atom.t<
  'value,
  Atom.Actions.set<'value>,
  [Atom.Tags.r | Atom.Tags.w | Atom.Tags.p | Atom.Tags.re],
> = "atomWithReset"
