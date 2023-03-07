type t<'data> = {
  state: [#loading | #hasError | #hasData],
  data: option<'data>,
  error: option<string>,
}

// type component<'data> = (
//   t<'data>,
//   React.element,
//   string => React.element,
//   'data => React.element,
// ) => React.element

// let createComponent: component<'data> = (
//   loadable,
//   loadingComponent,
//   errorComponent,
//   dataComponent,
// ) => {
//   switch (loadable.state, loadable.error, loadable.data) {
//   | (#hasError, Some(e), _) => errorComponent(e)
//   | (#hasData, _, Some(d)) => dataComponent(d)
//   | _ => loadingComponent
//   }
// }

/** Can be used if you don't want async atoms to suspend or throw to an error boundary.

```rescript
let atom = Jotai.Atom.makeThunk(async () => "stuff")
let loadableAtom = Jotai.Utils.Loadable.make(atom)

// inside component:
let value = Jotai.Utils.Loadable.useLoadableValue(loadableAtom)
{switch (value.state, value.data, value.error) {
  | (#hasData, Some(d), _) => <p>{("Data: " ++ d)->React.string}</p>
  | (#hasError, _, Some(e)) => <p>{e->React.string}</p>
  | _ => <p>{"Loading..."->React.string}</p>
}}
```
*/
@module("jotai/utils")
external make: Atom.t<promise<'data>, _, 'tags> => Atom.t<t<'data>, Atom.Actions.none, 'tags> =
  "loadable"

/** Hook to use a loadable atom.

```rescript
// inside component:
let value = Jotai.Utils.Loadable.useLoadableValue(loadableAtom)
```

*/
@module("jotai")
external useLoadableValue: Atom.t<t<'data>, _, _> => t<'data> = "useAtomValue"
