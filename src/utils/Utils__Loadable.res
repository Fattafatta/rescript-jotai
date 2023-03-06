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

@module("jotai/utils")
external make: Atom.t<promise<'data>, _, 'tags> => Atom.t<t<'data>, Atom.Actions.none, 'tags> =
  "loadable"

@module("jotai")
external useLoadableValue: Atom.t<t<'data>, _, _> => t<'data> = "useAtomValue"
