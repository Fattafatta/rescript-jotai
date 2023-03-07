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
@get
external get: t => get<'value, _, _> = "get"

/** Sets a new value of a given atom in the store.

```rescript
Jotai.Store.set(store, atom, 1); 
```
*/
@get
external set: t => set<'value, _, _> = "set"

/** Subscripe to changes of a given atom in the store. Returns a function to unsubscribe.

```rescript
let unsub = Jotai.Store.sub(store, atom, () => {
  Js.Console.log2("atom value is changed to", Jotai.Store.get(store, atom))
})

// unsub() to unsubscribe
```
*/
@get
external sub: t => sup<_, _, _> = "sub"

/** This hook returns a store within the component tree.

```rescript
let store = Jotai.Store.useStore()
```
*/
@module("Jotai")
external useStore: unit => t = "useStore"
