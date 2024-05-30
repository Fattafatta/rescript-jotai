// TYPES
/** Tags are used to restrict (or allow) operations on atoms. For example, some hooks can
only be used on `#primitive` atoms, or some atoms can be `#resettable`. Tags help transfer the 
flexibility of Jotai into the strictly typed world of ReScript.
*/
module Tags = {
  type r = [#readable]
  type w = [#writable]
  type p = [#primitive]
  type re = [#resettable]
  type all = [r | w | p | re]
}

/** Readonly atoms have no setter, while writeonly atoms have no getter but one is required in 
the type signature. Setting an explicit none type prevents compiler problems with type annotation.
*/
type none

/** Atoms use different functions to update their values. For example an `AtomWithReducer` provides
a `dispatch` function that has an 'action parameter.

```rescript
let (value, dispatch) = Atom.use(atomWithReducer)
dispatch(Increment(1))

let (value, setValue) = Atom.use(primitiveAtom)
setValue(prev => prev + 1)
```
*/
module Actions = {
  type t<'action>
  type set<'value> = t<('value => 'value) => unit>
  type update<'value> = t<'value => unit>
  type dispatch<'action> = t<'action => unit>
  type none = t<none>
}

/** Atoms have a value, a setter function (from `Atom.Actions`), and a set of
tags that restrict which operations are allowed on the atom (e.g is the atom `#resettable`).
Normally the type will be inferred automatically. If annotation is required it should be
sufficient to provide the first type (the value).

```rescript
let atom: Jotai.Atom.t<int, Actions.set<int>, [#readable | #writable | #...]> = Jotai.Atom.make(1)
```
*/
type t<'value, 'action, 'tags>
  constraint 'tags = [< Tags.all] constraint 'action = Actions.t<'setValue>

type set<'value, 'action, 'tags> = t<'value, 'action, 'tags> constraint 'tags = [> Tags.w]

type get<'value, 'action, 'tags> = t<'value, 'action, 'tags> constraint 'tags = [> Tags.r]

type getter = {get: 'value 'action 'tags. get<'value, Actions.t<'action>, 'tags> => 'value}

type setter = {
  get: 'value 'action 'tags. get<'value, Actions.t<'action>, 'tags> => 'value,
  set: 'value 'setValue 'action 'tags. (set<'value, Actions.t<'action>, 'tags>, 'setValue) => unit,
}

type getValue<'value> = getter => 'value
type setValue<'args> = (setter, 'args) => unit
type setValueAsync<'args> = (setter, 'args) => promise<unit>

// ATOMS
/** Create a (primitive) readable and writable atom (config).
CAUTION: Don't pass a function as argument to `Atom.make`. That would implicitly create a computed atom
and the compiler will produce weird types. Use `Atom.makeComputed` for that. 

```rescript
let atom1 = Jotai.Atom.make(1)
let atom2 = Jotai.Atom.make(["text"])
// DON'T do this:
let atom3 = Jotai.Atom.make(() => 1)
```
*/
@module("jotai")
external make: 'value => t<'value, Actions.set<'value>, [Tags.r | Tags.w | Tags.p]> = "atom"

/** Create a readonly atom from a function. The function can be async.

```rescript
let atom1 = Jotai.Atom.makeThunk(async () => 1)
// shorthand for
let atom2 = Jotai.Atom.makeComputed(async ({get}) => 1)
```
*/
@module("jotai")
external makeThunk: (unit => 'value) => t<'value, Actions.none, [#readable]> = "atom"

@module("jotai") @deprecated("[DEPRECATED] No longer needed. Use `Atom.makeThunk` instead.")
external makeAsync: (unit => promise<'value>) => t<promise<'value>, Actions.none, [#readable]> =
  "atom"

/** Create a computed readonly atom. A computed atom can combine any number of
readable atoms to create a single derived value. The syntax varies slightly from Jotai. 
Note the curly braces in `({get})`.
Requires `React.Suspense` or `Utils.Loadable` if the value is a promise (e.g. the getter is async)

```rescript
let atom1 = Jotai.Atom.make(1)
let atom2 = Jotai.Atom.makeComputed(({get}) => get(atom1) + 1)
let atom3 = Jotai.Atom.makeComputed(({get}) => get(atom1) + get(atom2) + 1)

// using async atoms requires React.Suspense
let atom4 = Jotai.Atom.makeComputed(async ({get}) => await get(asyncAtom) + 1)
```
*/
@module("./wrapper")
external makeComputed: getValue<'value> => t<'value, Actions.none, [#readable]> = "atomWrapped"

/** (Requires React.Suspense or Utils.Loadable) Create a computed readonly atom with an async getter. It is
possible to combine sync and async atoms. All components will be notified when the returned promise resolves.

```rescript
let atom1 = Jotai.Atom.makeAsync(() => 1)
let atom2 = Jotai.Atom.makeComputedAsync(async ({get}) => {await get(atom1) + 2})
```
*/
@module("./wrapper")
@deprecated("[DEPRECATED] No longer needed. Use `Atom.makeComputed` instead.")
external makeComputedAsync: getValue<'value> => t<'value, Actions.none, [#readable]> = "atomWrapped"

/** Create a computed atom that supports read and write. The getter may by async, 
but the setter must be synchronous. For async setters use `makeComputedAsync`.

```rescript
let atom1 = Jotai.Atom.make(1)
let atom2 = Jotai.Atom.makeWritableComputed(
  ({get}) => get(atom1) + 1,
  ({get, set}, arg) => {
    atom1->set(get(atom1) + arg)
  },
)
```
*/
@module("./wrapper")
external makeWritableComputed: (
  getValue<'value>,
  setValue<'args>,
) => t<'value, Actions.update<'args>, [Tags.r | Tags.w]> = "atomWrapped"

/** Create a computed atom with asynchronous write (setter). Jotai supports async write
operations for computed atoms. Simply call 'set' when the promise resolves.

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
*/
@module("./wrapper")
external makeWritableComputedAsync: (
  getValue<'value>,
  setValueAsync<'args>,
) => t<'value, Actions.update<'args>, [Tags.r | Tags.w]> = "atomWrapped"

@module("./wrapper")
external _makeWOC: (
  Js.Nullable.t<none>,
  setValue<'args>,
) => t<'value, Actions.update<'args>, [Tags.w]> = "atomWrapped"

@module("./wrapper")
external _makeWOCAsync: (
  Js.Nullable.t<none>,
  setValueAsync<'args>,
) => t<'value, Actions.update<'args>, [Tags.w]> = "atomWrapped"

/** Create a writeOnly computed atom. (Note: Sometimes the type can not be inferred 
automatically and has to be annotated)

```rescript
let atom1 = make(1)
let atom2: Jotai.Atom.t<int, _, _> = Jotai.Atom.makeWriteOnlyComputed(({get, set}, args) =>
  atom1->set(get(atom1) + args)
)
```
*/
@deprecated("[DEPRECATED] Use `Atom.makeWriteOnly` instead.")
let makeWriteOnlyComputed = getSet => _makeWOC(Js.Nullable.null, getSet)

/** Create a writeOnly computed atom. (Note: Sometimes the type can not be inferred 
automatically and has to be annotated)

```rescript
let atom1 = make(1)
let atom2: Jotai.Atom.t<int, _, _> = Jotai.Atom.makeWriteOnly(({get, set}, args) =>
  atom1->set(get(atom1) + args)
)
```
*/
let makeWriteOnly = getSet => _makeWOC(Js.Nullable.null, getSet)

/** Create a writeOnly computed async atom (i.e. the setter is an async function)

```rescript
let atom1 = make(1)
let atom2 = Jotai.Atom.makeWriteOnlyAsync(async ({get, set}, args) => atom1->set(get(atom1) + args))

```
*/
let makeWriteOnlyAsync = getSet => _makeWOCAsync(Js.Nullable.null, getSet)

// HOOKS
/** Standard hook to use with read/write synchronous atoms.
(For handling of readOnly/writeOnly atoms see `Jotai.useAtomValue` or `Jotai.useSetAtom`)

```rescript
let atom1 = Jotai.Atom.make(1)
let (value, setValue) = Jotai.Atom.useAtom(atom1) 
```
*/
@module("jotai")
external useAtom: t<'value, Actions.t<'action>, [> Tags.r | Tags.w]> => ('value, 'action) =
  "useAtom"

/** Standard hook to use with read/write async atoms (i.e. all atoms that contain a promise). 
(For handling of readOnly/writeOnly atoms see `Jotai.useAtomValueAsync` or `Jotai.useSetAtom`)

```rescript
let atom1 = Jotai.Atom.makeAsync(async () => 1)
let (value, setValue) = Jotai.Atom.useAtomAsync(atom1) 
```
*/
@module("jotai")
external useAtomAsync: t<promise<'value>, Actions.t<'action>, [> Tags.r | Tags.w]> => (
  'value,
  'action,
) = "useAtom"

@deprecated("[DEPRECATED] Use `Atom.useAtom` instead.") @module("jotai")
external use: t<'value, Actions.t<'action>, [> Tags.r | Tags.w]> => ('value, 'action) = "useAtom"

type setAtom<'value> = ('value => 'value) => unit
type onUnmount = unit => unit
/** `onMount` is a function which takes a function setAtom and returns `onUnmount` function 
optionally. The `onMount` function is called when the atom is first used in a provider, and `onUnmount` is
called when it’s no longer used.

```rescript
let atom1 = Jotai.Atom.make(1)
atom1->Jotai.Atom.onMount(setAtom => {
  setAtom(a => a + 1) // increment count on mount
  () => () // return onUnmount function
})
```
*/
@set
external onMount: (t<'value, _, [> Tags.w]>, setAtom<'value> => onUnmount) => unit = "onMount"

/**
`debugLabel` is a function that takes an atom and a string and adds a label to the atom for debugging purposes.
See: https://jotai.org/docs/guides/debugging#debug-labels

```rescript
let atom1 = Jotai.Atom.make(1)
atom1->Jotai.Atom.debugLabel("count")
```
 */
@set
external debugLabel: (t<'value, _, _>, string) => unit = "debugLabel"

// useUpdateAtom
/** A hook that returns only the update function of an atom. Can be used to access writeOnly atoms.

```rescript
let atom = Jotai.Atom.make(1)
let setValue = Jotai.Atom.useSetAtom(atom) 
setValue(prev => prev + 1)
```
*/
@module("jotai")
external useSetAtom: t<'value, Actions.t<'action>, [> Tags.w]> => 'action = "useSetAtom"

// useAtomValue
/** A hook that returns only the value of a synchronous atom. Can be used to access readOnly atoms.

```rescript
let atom = Jotai.Atom.make(1)
let value = Jotai.Atom.useAtomValue(atom) 
```
*/
@module("jotai")
external useAtomValue: t<'value, _, [> Tags.r]> => 'value = "useAtomValue"

/** A hook that returns only the value of an async atom (i.e. the atom contains a promise).
Can be used to access readOnly async atoms. 

```rescript
let atom = Jotai.Atom.make(1)
let value = Jotai.Atom.useAtomValue(atom) 
```
*/
@module("jotai")
external useAtomValueAsync: t<promise<'value>, _, [> Tags.r]> => 'value = "useAtomValue"
