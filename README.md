# rescript-jotai

[ReScript](https://rescript-lang.org/) bindings for [Jotai](https://github.com/pmndrs/jotai). Primitive and flexible state management for React.

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

A Provider works just like React context provider. If you don't use a Provider, it works as provider-less mode with a default store. A Provider will be necessary if we need to hold different atom values for different component trees.

```rescript
module App = {
  @react.component
  let make = () =>
    <Jotai.Provider>
      ...
    </Jotai.Provider>
}
```

### Create atoms

#### Atom type

Atoms have a value, a setter function (from `Atom.Actions`), and a set of tags that restrict which operations are allowed on the atom (e.g is the atom `#resettable`).
Normally the type will be inferred automatically. If annotation is required it should be sufficient to provide the first type (the value).

Example:

```rescript
let atom: Jotai.Atom.t<int, _, _> = Jotai.Atom.make(1)
```

#### Primitive atom (`Jotai.Atom.make`)

Create a (primitive) readable and writable atom.

```rescript
let atom1 = Jotai.Atom.make(1)
let atom2 = Jotai.Atom.make('text')
```

#### Computed atom (`Jotai.Atom.makeComputed`)

Create a computed readonly atom. A computed atom can combine any number of readable atoms to create a single derived value. The syntax varies slightly from Jotai.
Note the curly braces in `({get})`.

```rescript
let atom1 = Jotai.Atom.make(1)
let atom2 = Jotai.Atom.makeComputed(({get}) => get(atom1) + 1)
let atom3 = Jotai.Atom.makeComputed(({get}) => get(atom1) + get(atom2) + 1)
```

#### Computed async atom (`Jotai.Atom.makeComputedAsync`)

(Requires React.Suspense) Create an computed readonly atom with an async getter. All components will be notified when the returned promise resolves.

```rescript
let atom1 = Jotai.Atom.make(1)
let atom2 = Jotai.Atom.makeComputedAsync(({get}) => {
  Js.Promise.make((~resolve, ~reject as _) => {
    let count = atom1->get + 1
    Js.Global.setTimeout(() => resolve(. count), 100)->ignore
  })
})
```

#### Computed writable atom (`Jotai.Atom.makeWritableComputed`)

Create a computed atom that supports read and write.

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

Create a computed atom with asynchronous write. Jotai supports async write operations for computed atoms. Simply call 'set' when the promise resolves.

```rescript
let atom1 = Jotai.Atom.make(1)
let atom2 = Jotai.Atom.makeWritableComputedAsync(
  ({get}) => get(atom1) + 1,
  ({get, set}, arg) => {
    Js.Promise.make((~resolve, ~reject as _) => {
      let count = get(atom1) + arg
      Js.Global.setTimeout(() => resolve(. count), 100)->ignore
    })->Js.Promise.then_(value => {
      atom1->set(value)
      Js.Promise.resolve()
    }, _)
  },
)
```

#### Computed writeonly atom (`Jotai.Atom.makeWriteOnlyComputed`)

Create a writeOnly computed atom.(Note: Sometimes the type can not be inferred and has to be annotated)

```rescript
let atom1 = make(1)
let atom2: Jotai.Atom.t<int, _, _> = Jotai.Atom.makeWriteOnlyComputed(({get, set}, args) =>
  atom1->set(get(atom1) + args)
)
```

#### OnMount (`Jotai.Atom.onMount`)

The `onMount` function will be invoked when the atom is first used in a provider,
and `onUnmount` will be invoked when it's not used.

```rescript
let atom1 = Jotai.Atom.make(1)
atom1->Jotai.Atom.onMount(setAtom => {
  setAtom(a => a + 1) // increment count on mount
  () => () // return onUnmount function
})
```

### Standard hook

#### Using read/write atoms (`Jotai.Atom.use`)

Standard hook to use with read/write atoms.
(For handling of readOnly/writeOnly atoms see `Jotai.Utils`)

```rescript
let atom1 = Jotai.Atom.make(1)
let (value, setValue) = Jotai.Atom.use(atom1)
```

### Utils

#### Atom with localStorage (`Jotai.Utils.AtomWithStorage.make`)

Creates an atom with a value persisted in `localStorage`
Currently only `localStorage` is supported.

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

Create a resettable primitive atom. Its default value can be specified
with a read function instead of a static initial value.

```rescript
let atom1 = Jotai.Atom.make(1)
let atom2 = Jotai.Utils.AtomWithDefault.make(({get}) => atom1->get + 1)
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
let (value, dispatch) = Atom.use(atom)
Inc(1)->dispatch
```

#### AtomFamily (`Jotai.Utils.AtomFamily`)

Creates an atomFamily. If the compiler has trouble inferring the type,
it is recommended to set the type directly on the function param.

```rescript
let atomFamily = Jotai.Utils.AtomFamily.make((name: string) => Jotai.Atom.make(name))
let atom = atomFamily(\"text\")
```

##### With Equals function (`Jotai.Utils.AtomFamily.makeWithEqual`)

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
Jotai.Utils.AtomFamily.remove(atomFamily, \"text\")
```

##### SetShouldRemove

Register a shouldRemove function.

```rescript
let shouldRemove = (createdAt, param) => param == \"test\"
Jotai.Utils.AtomFamily.setShouldRemove(atomFamily, shouldRemove)
```

Unregister the shouldRemove function.

```rescript
Jotai.Utils.AtomFamily.setShouldRemoveUnregister(atomFamily, Js.Null.empty)
```

### Utils Hooks

#### Get only the update function (`Jotai.Utils.useUpdateAtom`)

A hook that returns only the update function of an atom. Can be used to access writeOnly atoms.

```rescript
let atom = Jotai.Atom.make(1)
let setValue = Jotai.Utils.useUpdateAtom(atom)
setValue(prev => prev + 1)
```

#### Get only the value (`Jotai.Utils.useAtomValue`)

A hook that returns only the value of an atom. Can be used to access readOnly atoms.

```rescript
let atom = Jotai.Atom.make(1)
let value = Jotai.Utils.useAtomValue(atom)
```

#### Reset an atom (`Jotai.Utils.useResetAtom`)

Returns a function that can be used to reset a resettable atom.

```rescript
let atom = Jotai.Utils.AtomWithReset(1)  // value: 1
let (_, setValue) = Jotai.Atom.use(atom)
setValue(2)  // value: 2
let resetValue = Jotai.Utils.useResetAtom(atom)
resetValue()  // value back to: 1
```

#### Pass a reducer to a writable atom (`Jotai.Utils.useReducerAtom`)

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

## Alternatives

This package was greatly inspired by [re-jotai](https://github.com/gaku-sei/re-jotai). I just preferred to have a different syntax for the get/set functions.

## Missing functions from Jotai

These functions are not (yet) supported.

- atomWithObservable
- atomWithHash
- atomFamily
- selectAtom
- useAtomCallback
- freezeAtom
- splitAtom
- waitForAll
- useHydrateAtoms
