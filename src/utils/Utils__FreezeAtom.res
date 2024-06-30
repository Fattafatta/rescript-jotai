/** Creates an atom that is read-only and deeply frozen from an existing atom. 

```rescript
let atom = Jotai.Atom.make(1)
let freeze = Jotai.Utils.FreezeAtom.freezeAtom(atom)
```
 */
@module("jotai/utils")
external freezeAtom: Atom.t<'value, 'any, [> Atom.Tags.r]> => Atom.t<
  'value,
  Atom.Actions.none,
  Atom.Tags.r,
> = "freezeAtom"
