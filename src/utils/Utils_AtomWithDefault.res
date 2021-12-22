@ocaml.doc("Create a resettable primitive atom. Its default value can be specified
with a read function instead of a static initial value.

```rescript
let atom1 = Jotai.Atom.make(1)
let atom2 = Jotai.Utils.AtomWithDefault.make(({get}) => atom1->get + 1)
```
")
@module("../wrapper")
external make: Atom.getValue<'value> => Atom.t<
  'value,
  Atom.Actions.set<'value>,
  [Atom.Tags.r | Atom.Tags.w | Atom.Tags.p | Atom.Tags.re],
> = "atomWithDefaultWrapped"

@module("../wrapper")
external makeAsync: Atom.getValueAsync<'value> => Atom.t<
  'value,
  Atom.Actions.set<'value>,
  [Atom.Tags.r | Atom.Tags.w | Atom.Tags.p | Atom.Tags.re],
> = "atomWithDefaultWrapped"
