type t<'param, 'action, 'tags> = 'param => Atom.t<'param, 'action, 'tags>

/** Creates an atomFamily. If the compiler has trouble inferring the type,
it is recommended to annotate the type directly on the function param.

```rescript
let atomFamily = Jotai.Utils.AtomFamily.make((name: string) => Jotai.Atom.make(name))
let atom = atomFamily("text")
```
*/
@module("jotai/utils")
external make: t<'param, 'action, 'tags> => t<'param, 'action, 'tags> = "atomFamily"

/** Creates an atomFamily with a supplied comparison function

```rescript
let atomFamWithEqual = Jotai.Utils.AtomFamily.makeWithEqual(
  name => Jotai.Atom.make(name),
  (strA, strB) => strA == strB,
)
```
*/
@module("jotai/utils")
external makeWithEqual: (
  t<'param, 'action, 'tags>,
  ('param, 'param) => bool,
) => t<'param, 'action, 'tags> = "atomFamily"

/** Removes an atom from an atomFamily.

```rescript
Jotai.Utils.AtomFamily.remove(atomFamily, \"text\")
```
*/
@set
external remove: (t<'param, 'action, 'tags>, 'param) => unit = "remove"

/** Registers a shouldRemove function.

```rescript
let shouldRemove = (createdAt, param) => param == \"test\"
Jotai.Utils.AtomFamily.setShouldRemove(atomFamily, shouldRemove)
```
*/
@set
external setShouldRemove: (t<'param, 'action, 'tags>, (int, 'param) => bool) => unit =
  "setShouldRemove"

/** Unregisters the shouldRemove function.

```rescript
Jotai.Utils.AtomFamily.setShouldRemoveUnregister(atomFamily, Js.Null.empty)
```
*/
@set
external setShouldRemoveUnregister: (t<'param, 'action, 'tags>, Js.Null.t<'null>) => unit =
  "setShouldRemove"
