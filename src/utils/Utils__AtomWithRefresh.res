/** Creates an atom that we can refresh, which is to force reevaluating the read function..

```rescript
let atom1 = Jotai.Utils.AtomWithRefresh.make(_ => 1)
let (value, refresh) = Jotai.Utils.useRefreshAtom(atom1) 
refresh()
```
*/
@module("jotai/utils")
external make: Atom.getValue<'value> => Atom.t<
  'value,
  Atom.Actions.none,
  [Atom.Tags.r | Atom.Tags.re | Atom.Tags.fr],
> = "atomWithRefresh"

/** Creates a writeable atom that we can refresh, which is to force reevaluating the read function..

```rescript
let atom1 = Jotai.Utils.AtomWithRefresh.makeComputed(
({get}) => 1,
({get, set}, arg) => {/* set something */},
)
let (value, update) = Jotai.Utils.useAtom(atom1) 
```
*/
@module("../wrapper")
external makeComputed: (
  Atom.getValue<'value>,
  Atom.setValue<'args>,
) => Atom.t<
  'value,
  Atom.Actions.update<'args>,
  [Atom.Tags.r | Atom.Tags.w | Atom.Tags.re | Atom.Tags.fr],
> = "atomWithRefreshWrapped"
