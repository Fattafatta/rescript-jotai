# rescript-jotai

[ReScript](https://rescript-lang.org/) bindings for [Jotai](https://github.com/pmndrs/jotai). Primitive and flexible state management for React.

Versions below 0.3.0 support Jotai v1.

Versions 0.3.0 and higher support Jotai v2. They also require at least rescript 10.1 (for async/await) and react 18+.

Versions 0.4.0 and higher support Jotai v2 with rescript 11 and react 18+.

## Installation

Install with `npm`:

```bash
npm install jotai @fattafatta/rescript-jotai
```

Or install with `yarn`:

```bash
yarn add jotai @fattafatta/rescript-jotai
```

Add `@fattafatta/rescript-jotai` as a dependency to your `bsconfig.json`:

```json
"bs-dependencies": ["@rescript/react", "@fattafatta/rescript-jotai"]
```

## Usage

### Provider

A Provider works just like React context provider. If you don't use a Provider, it works as provider-less mode with a default store. A Provider will be necessary if we need to hold different atom values for different component trees. The store property is optional

```rescript
let store = Jotai.Store.make()

module App = {
  @react.component
  let make = () =>
    <Jotai.Provider store={store}>
      ...
    </Jotai.Provider>
}
```

### Store

Atoms are always stored in a store. If no specific store is passed to `Provider` a default store will be created.

#### Create a store (`Jotai.Store.make`)

Creates a store.

```rescript
let store = Jotai.Store.make();
```

#### Get default store (`Jotai.Store.getDefaultStore`)

Get the default store that is created if no specific store was provided.

```rescript
let store = Jotai.Store.getDefaultStore();
```

#### Access a store

A store supports 3 functions to access its content.

`get` for getting atom values.

```rescript
let value = Jotai.Store.get(store, atom);
```

`set` for setting atom values.

```rescript
Jotai.Store.set(store, atom, 1);
```

`sub` for subscribing to atom changes. Returns a function to unsubscribe.

```rescript
let unsub = Jotai.Store.sub(store, atom, () => {
  Js.Console.log2("atom value is changed to", Jotai.Store.get(store, atom))
})

// unsub() to unsubscribe
```

### Create atoms

In Jotai there is no distinction between normal and async atoms (i.e. atoms that hold promise). So in Jotai hooks will always return the resolved value.
It's not possible to reproduce this one to one in ReScript. Therefore, wherever necessary, functions are provided for normal atoms, and separate `*Async` functions are provided to handle atoms with promises. (e.g. `useAtom` and `useAtomAsync`).

CAUTION: Using the wrong function may not result in compile errors, but very likely runtime errors. As a simple guideline just remember that a hook should never return a promise. If the return type is `promise<>` use the async version of the function instead.

#### Atom type

Atoms have a value, a setter function (from `Atom.Actions`), and a set of tags that restrict which operations are allowed on the atom (e.g is the atom `#resettable`).
Normally the type will be inferred automatically. If annotation is required it should be sufficient to provide the first type (the value).

Example:

```rescript
let atom: Jotai.Atom.t<int, _, _> = Jotai.Atom.make(1)
```

#### Primitive atom (`Jotai.Atom.make`)

Create a (primitive) readable and writable atom (config).

CAUTION: Don't pass a function as argument to `Atom.make`. That would implicitly create a computed atom and the compiler will produce weird types. Use `Atom.makeComputed` for that.

```rescript
let atom1 = Jotai.Atom.make(1)
let atom2 = Jotai.Atom.make(["text"])
// DON'T do this:
let atom3 = Jotai.Atom.make(() => 1)
```

#### Atom from thunk (`Jotai.Atom.makeThunk`)

Create a readonly atom from a function. The function can be async.

```rescript
let atom1 = Jotai.Atom.makeThunk(async () => 1)
// shorthand for
let atom2 = Jotai.Atom.makeComputed(async ({get}) => 1)
```

#### Computed atom (`Jotai.Atom.makeComputed`)

Create a computed readonly atom. A computed atom can combine any number of readable atoms to create a single derived value. The syntax varies slightly from Jotai.
Note the curly braces in `({get})`. Requires `React.Suspense` or `Utils.Loadable` if the value is a promise (e.g. the getter is async)

```rescript
let atom1 = Jotai.Atom.make(1)
let atom2 = Jotai.Atom.makeComputed(({get}) => get(atom1) + 1)
let atom3 = Jotai.Atom.makeComputed(({get}) => get(atom1) + get(atom2) + 1)

// using async atoms requires React.Suspense
let atom4 = Jotai.Atom.makeComputed(async ({get}) => await get(asyncAtom) + 1)
```

#### (DEPRECATED) Computed async atom (`Jotai.Atom.makeComputedAsync`)

This function is no longer necessary. Atoms no fully support async getters out of the box.

(Requires React.Suspense) Create an computed readonly atom with an async getter. All components will be notified when the returned promise resolves.

```rescript
let atom1 = Jotai.Atom.make(1)
let atom2 = Jotai.Atom.makeComputedAsync(async ({get}) => {atom1->get + 1})
```

#### Computed writable atom (`Jotai.Atom.makeWritableComputed`)

Create a computed atom that supports read and write. The getter may by async, but the setter must be synchronous. For async setters use `makeComputedAsync`.

```rescript
let atom1 = Jotai.Atom.make(1)
let atom2 = Jotai.Atom.makeWritableComputed(
  ({get}) => get(atom1) + 1,
  ({get, set}, arg) => {
    atom1->set(get(atom1) + arg)
  },
)
```

#### Computed writable async atom (`Jotai.Atom.makeWritableComputedAsync`)

Create a computed atom with asynchronous write (setter). Jotai supports async write operations for computed atoms. Simply call 'set' when the promise resolves.

```rescript
let atom1 = Jotai.Atom.make(1)
let atom2 = Jotai.Atom.makeWritableComputedAsync(
  ({get}) => get(atom1) + 1,
  async ({get, set}, arg) => {
    // do async stuff
    set(atom1, get(atom1) + arg)
  },
)
```

#### Computed writeonly atom (`Jotai.Atom.makeWriteOnly`)

Create a writeOnly computed atom. (Note: Sometimes the type can not be inferred automatically and has to be annotated)

```rescript
let atom1 = make(1)
let atom2: Jotai.Atom.t<int, _, _> = Jotai.Atom.makeWriteOnly(({get, set}, args) =>
  atom1->set(get(atom1) + args)
)
```

#### Computed writeonly async atom (`Jotai.Atom.makeWriteOnlyAsync`)

Create a writeOnly computed async atom (i.e. the setter is an async function)

```rescript
let atom1 = make(1)
let atom2 = Jotai.Atom.makeWriteOnlyAsync(async ({get, set}, args) => atom1->set(get(atom1) + args))

```

#### OnMount (`Jotai.Atom.onMount`)

`onMount` is a function which takes a function setAtom and returns `onUnmount` function optionally. The `onMount` function is called when the atom is first used in a provider, and `onUnmount` is called when it’s no longer used.

```rescript
let atom1 = Jotai.Atom.make(1)
atom1->Jotai.Atom.onMount(setAtom => {
  setAtom(a => a + 1) // increment count on mount
  () => () // return onUnmount function
})
```

### Core hooks

#### Using read/write atoms (`Jotai.Atom.useAtom`)

Standard hook to use with read/write synchronous atoms. (For handling of readOnly/writeOnly atoms see `Jotai.useAtomValue` or `Jotai.useSetAtom`)

```rescript
let atom1 = Jotai.Atom.make(1)
let (value, setValue) = Jotai.Atom.useAtom(atom1)
```

#### Using async read/write atoms (`Jotai.Atom.useAtomAsync`)

Standard hook to use with read/write async atoms (i.e. all atoms that contain a promise). (For handling of readOnly/writeOnly atoms see `Jotai.useAtomValueAsync` or `Jotai.useSetAtom`)

```rescript
let atom1 = Jotai.Atom.makeAsync(async () => 1)
let (value, setValue) = Jotai.Atom.useAtomAsync(atom1)
```

#### Get only the update function (`Jotai.Atom.useSetAtom`)

A hook that returns only the update function of an atom. Can be used to access writeOnly atoms.

```rescript
let atom = Jotai.Atom.make(1)
let setValue = Jotai.Atom.useSetAtom(atom)
setValue(prev => prev + 1)
```

#### Get only the value (`Jotai.Atom.useAtomValue`)

A hook that returns only the value of a synchronous atom. Can be used to access readOnly atoms.

```rescript
let atom = Jotai.Atom.make(1)
let value = Jotai.Atom.useAtomValue(atom)
```

#### Get the value from an async atom (`Jotai.Atom.useAtomValueAsync`)

A hook that returns only the value of an async atom (i.e. the atom contains a promise). Can be used to access readOnly async atoms.

```rescript
let atom = Jotai.Atom.make(1)
let value = Jotai.Atom.useAtomValue(atom)
```

### Utils

#### Atom with localStorage (`Jotai.Utils.AtomWithStorage.make`)

Creates an atom with a value persisted in `localStorage`. Currently only `localStorage` is supported.

```rescript
let atom1 = Jotai.Utils.AtomWithStorage.make('storageKey', 1)
```

#### Resettable atom (`Jotai.Utils.AtomWithReset.make`)

Creates an atom that can be reset to its initialValue with the `useResetAtom` hook.

```rescript
let atom = Jotai.Utils.AtomWithReset.make(1)
// ... change value ...
let reset = Jotai.Utils.useResetAtom(atom)
reset()
```

#### Atom with default (`Jotai.Utils.AtomWithDefault.make`)

Create a resettable, writable atom. Its default value can be specified with a read function instead of an initial value. This function support sync and async getters.

```rescript
let atom1 = Jotai.Atom.make(1)
let atom2 = Jotai.Utils.AtomWithDefault.make(({get}) => atom1->get + 1)
// async
let atom3 = Jotai.Atom.makeAsync(async () =>1)
let atom4 = Jotai.Utils.AtomWithDefault.make(async({get}) => await atom3->get + 1)
```

#### Atom with Reducer (`Jotai.Utils.AtomWithReducer.make`)

Creates an atom that uses a reducer to update its value.

```rescript
type actionType = Inc(int) | Dec(int)
let countReducer = (prev, action) => {
  switch action {
  | Inc(num) => prev + num
  | Dec(num) => prev - num
  }
}
let atom = Utils.AtomWithReducer.make(0, countReducer)
let (value, dispatch) = Atom.useAtom(atom)
Inc(1)->dispatch
```

#### AtomFamily (`Jotai.Utils.AtomFamily`)

Creates an atomFamily. If the compiler has trouble inferring the type, it is recommended to set the type directly on the function param.

```rescript
let atomFamily = Jotai.Utils.AtomFamily.make((name: string) => Jotai.Atom.make(name))
let atom = atomFamily("text")
```

##### With Equals function

Creates an atomFamily with a supplied comparison function

```rescript
let atomFamWithEqual = Jotai.Utils.AtomFamily.makeWithEqual(
  name => Jotai.Atom.make(name),
  (strA, strB) => strA == strB,
)
```

##### Remove

Removes an atom from an atomFamily.

```rescript
Jotai.Utils.AtomFamily.remove(atomFamily, "text")
```

##### SetShouldRemove (`Jotai.Utils.AtomFamily.setShouldRemove`)

Register a shouldRemove function.

```rescript
let shouldRemove = (createdAt, param) => param == "test"
Jotai.Utils.AtomFamily.setShouldRemove(atomFamily, shouldRemove)
```

Unregister the shouldRemove function with `Jotai.Utils.AtomFamily.setShouldRemoveUnregister`.

```rescript
Jotai.Utils.AtomFamily.setShouldRemoveUnregister(atomFamily, Js.Null.empty)
```

#### Loadable (`Jotai.Utils.Loadable`)

Can be used if you don't want async atoms to suspend or throw to an error boundary.

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

#### FreezeAtom (`Jotai.Utils.FreezeAtom`)

Creates an atom that is read-only and deeply frozen from an existing atom.

```rescript
let atom = Jotai.Atom.make(1)
let freeze = Jotai.Utils.FreezeAtom.freezeAtom(atom)
```

#### SelectAtom (`Utils.SelectAtom.make`)

Derives a readonly atom that selects a slice of the state of an atom.

```rescript
let a = Atom.make(1)
let b = Utils.SelectAtom.make(a, (a, _prev) => a + 1)
```

Derives a readonly atom that selects a slice of the state of an atom with a custom equality function.

```rescript
let a = Atom.make(1)
let b = Utils.SelectAtom.makeWithEquality(a, (a, _prev) => a + 1, (a, b) => a == b)
```

#### AtomWithRefresh (`Jotai.Utils.AtomWithRefresh.make`)

Creates an atom that we can refresh, which is to force reevaluating the read function..

```rescript
let atom1 = Jotai.Utils.AtomWithRefresh.make(_ => 1)
let (value, refresh) = Jotai.Utils.useRefreshAtom(atom1)
refresh()
```

Creates a **writeable** atom that we can refresh, which is to force reevaluating the read function..

```rescript
let atom1 = Jotai.Utils.AtomWithRefresh.makeComputed(
({get}) => 1,
({get, set}, arg) => {/* set something */},
)
let (value, update) = Jotai.Utils.useAtom(atom1)
```

### Utils Hooks

#### Reset an atom (`Jotai.Utils.useResetAtom`)

Returns a function that can be used to reset a resettable atom.

```rescript
let atom = Jotai.Utils.AtomWithReset(1)  // value: 1
let (_, setValue) = Jotai.Atom.useAtom(atom)
setValue(2)  // value: 2
let resetValue = Jotai.Utils.useResetAtom(atom)
resetValue()  // value back to: 1
```

### Extensions

#### Cache (`Jotai.AtomWithCache.make`)

Requires `jotai-cache` package.

Create a read-only atom with cache from a function. The function can be async.

Options:
size (optional): maximum size of cache items.
shouldRemove (optional): a function to check if cache items should be removed.
areEqual (optional): a function to compare atom values.

```rescript
let atom1 = Jotai.AtomWithCache.make(async ({get}) => 1, ~option={size: 5, areEqual=(v1, v2) => v1 == v2})
```

## Refresh an atom (`Jotai.Utils.useRefreshAtom`)

Hook to refresh an `AtomWithRefresh`. (This is the equivalent of calling the set function without arguments in Jotai)

```rescript
let atom1 = Jotai.Utils.AtomWithRefresh.make(_ => 1)
let (value, refresh) = Jotai.Utils.useRefreshAtom(atom1)
refresh()
```

#### (deprecated) Pass a reducer to a writable atom (`Jotai.Utils.useReducerAtom`)

Allows to use a reducer function with a primitive atom.

```rescript
type actionType = Inc(int) | Dec(int)
let countReducer = (prev, action) => {
  switch action {
  | Inc(num) => prev + num
  | Dec(num) => prev - num
  }
}
let atom = Jotai.Atom.make(0)
let (value, dispatch) = Jotai.Utils.useReducerAtom(atom, countReducer)
Inc(1)->dispatch
```

#### Use a loadable atom (`Jotai.Utils.Loadable.useLoadableValue`)

Hook to use a loadable atom.

```rescript
// inside component:
let value = Jotai.Utils.Loadable.useLoadableValue(loadableAtom)
```

## Alternatives

This package was greatly inspired by [re-jotai](https://github.com/gaku-sei/re-jotai). I just preferred to have a different syntax for the get/set functions.

## Missing functions from Jotai

These functions are not (yet) supported.

- atomWithObservable
- atomWithHash
- selectAtom
- useAtomCallback
- freezeAtom
- splitAtom
- useHydrateAtoms
- options for useAtom
- Vanilla library
- multi argument setters (write functions). This can be accoplished by simly using an array or a record as argument instead.
