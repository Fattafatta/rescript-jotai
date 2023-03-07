/** Create a resettable, writable atom. Its default value can be specified
with a read function instead of an initial value. This function support sync and async getters.

```rescript
let atom1 = Jotai.Atom.make(1)
let atom2 = Jotai.Utils.AtomWithDefault.make(({get}) => atom1->get + 1)
// async
let atom3 = Jotai.Atom.makeAsync(async () =>1)
let atom4 = Jotai.Utils.AtomWithDefault.make(async({get}) => await atom3->get + 1)
```
*/
@module("../wrapper")
external make: Atom.getValue<'value> => Atom.t<
  'value,
  Atom.Actions.set<'value>,
  [Atom.Tags.r | Atom.Tags.w | Atom.Tags.re],
> = "atomWithDefaultWrapped"
