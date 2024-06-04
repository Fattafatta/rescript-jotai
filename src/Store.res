type t

/** Creates a store.

```rescript
let store = Jotai.Store.make(); 
```
*/
@module("jotai")
external make: unit => t = "createStore"

/** Get the default store that is created if no specific store was provided.

```rescript
let store = Jotai.Store.getDefaultStore(); 
```
*/
@module("jotai")
external getDefaultStore: unit => t = "getDefaultStore"

type unitToUnitFunc = unit => unit
type get<'value, 'action, 'tags> = Atom.t<'value, 'action, 'tags> => 'value
type set<'value, 'action, 'tags> = (Atom.t<'value, 'action, 'tags>, 'value) => unit
type sup<'value, 'action, 'tags> = (
  Atom.t<'value, 'action, 'tags>,
  unitToUnitFunc,
) => unitToUnitFunc

/** Returns the value of a given atom from the store.

```rescript
let value = Jotai.Store.get(store, atom); 
```
*/
@send
external get: (t, Atom.t<'value, _, [> Atom.Tags.r]>) => 'value = "get"

/** Sets a new value of a given atom in the store.

```rescript
Jotai.Store.set(store, atom, 1); 
```
*/
@send
external set: (t, Atom.t<'value, Jotai.Atom.Actions.set<'value>, [> Atom.Tags.w]>, 'value) => unit =
  "set"

/** Sets a new value of a writable computed atom in the store.

```rescript
Jotai.Store.update(store, atom, (value) => value + 1);
```
*/
@send
external update: (
  t,
  Atom.t<'value, Jotai.Atom.Actions.update<'value>, [> Atom.Tags.w]>,
  'value,
) => unit = "set"

/** Sets a new value of a given reducer atom in the store.

```rescript
Jotai.Store.dispatch(store, atom, Inc(1)); 
```
*/
@send
external dispatch: (
  t,
  Atom.t<'value, Jotai.Atom.Actions.dispatch<'action>, [> Atom.Tags.w]>,
  'action,
) => unit = "set"

/** Subscribe to changes of a given atom in the store. Returns a function to unsubscribe.

```rescript
let unsub = Jotai.Store.sub(store, atom, () => {
  Js.Console.log2("atom value is changed to", Jotai.Store.get(store, atom))
})

// unsub() to unsubscribe
```
*/
@send
external sub: (t, Atom.t<_, _, [> Atom.Tags.r]>, @uncurry unit => unit) => unitToUnitFunc = "sub"

/** This hook returns a store within the component tree.

```rescript
let store = Jotai.Store.useStore()
```
*/
@module("Jotai")
external useStore: unit => t = "useStore"
