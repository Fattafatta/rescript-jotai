// TYPES
@ocaml.doc("Tags are used to restrict (or allow) operations on atoms. For example, some hooks can
only be used on `#primitive`` atoms, or some atoms can be `#resettable`. Tags help transfer the 
flexibility of Jotai into the strictly typed world of ReScript.
")
module Tags = {
  type r = [#readable]
  type w = [#writable]
  type p = [#primitive]
  type re = [#resettable]
  type all = [r | w | p | re]
}

@ocaml.doc("Readonly atoms have no setter but one is required in the type signature.
Setting an explicit none type prevents compiler problems with type annotation.
")
type none

@ocaml.doc("Atoms use different functions to update their values. For example an 
`AtomWithReducer` provides a `dispatch` function that has an 'action parameter.

```rescript
let (value, dispatch) = Atom.use(atomWithReducer)
dispatch(Increment(1))

let (value, setValue) = Atom.use(primitiveAtom)
setValue(prev => prev + 1)
```
")
module Actions = {
  type t<'action>
  type set<'value> = t<('value => 'value) => unit>
  type update<'value> = t<'value => unit>
  type dispatch<'action> = t<'action => unit>
  type none = t<none>
}

@ocaml.doc("Atoms have a value, a setter function (from `Atom.Actions`), and a set of
tags that restrict which operations are allowed on the atom (e.g is the atom `#resettable`).

```rescript
let atom: Jotai.Atom.t<int, _, _> = Jotai.Atom.make(1)
```
")
type t<'value, 'action, 'tags>
  constraint 'tags = [< Tags.all] constraint 'action = Actions.t<'setValue>
type void // used for readonly atoms without setter

type set<'value, 'action, 'tags> = t<'value, 'action, 'tags> constraint 'tags = [> Tags.w]

type get<'value, 'action, 'tags> = t<'value, 'action, 'tags> constraint 'tags = [> Tags.r]

type getter = {get: 'value 'action 'tags. get<'value, Actions.t<'action>, 'tags> => 'value}
type setter = {
  get: 'value 'action 'tags. get<'value, Actions.t<'action>, 'tags> => 'value,
  set: 'value 'setValue 'action 'tags. (set<'value, Actions.t<'action>, 'tags>, 'setValue) => unit,
}

type getValue<'value> = getter => 'value
type getValueAsync<'value> = getter => promise<'value>
type setValue<'args> = (setter, 'args) => unit
type setValueAsync<'args> = (setter, 'args) => promise<unit>

// ATOMS
@ocaml.doc("Create a (primitive) readable and writable atom.

```rescript
let atom1 = Jotai.Atom.make(1)
let atom2 = Jotai.Atom.make('text')
```
")
@module("jotai")
external make: 'value => t<'value, Actions.set<'value>, [Tags.r | Tags.w | Tags.p]> = "atom"

@ocaml.doc("Create an atom from an async function.

```rescript
let atom1 = Jotai.Atom.makeAsync(async () => 1)
```
")
@module("jotai")
external makeAsync: (unit => promise<'value>) => t<
  'value,
  Actions.set<'value>,
  [Tags.r | Tags.w | Tags.p],
> = "atom"

@ocaml.doc("Create a computed readonly atom. A computed atom can combine any number of
readable atoms to create a single derived value. The syntax varies slightly from Jotai. 
Note the curly braces in `({get})`.

```rescript
let atom1 = Jotai.Atom.make(1)
let atom2 = Jotai.Atom.makeComputed(({get}) => get(atom1) + 1)
let atom3 = Jotai.Atom.makeComputed(({get}) => get(atom1) + get(atom2) + 1)
```
")
@module("./wrapper")
external makeComputed: getValue<'value> => t<'value, Actions.none, [Tags.r]> = "atomWrapped"

@ocaml.doc("(Requires React.Suspense) Create an computed readonly atom with an async getter.
All components will be notified when the returned promise resolves.

```rescript
let atom1 = Jotai.Atom.make(1)
let atom2 = Jotai.Atom.makeComputedAsync(async ({get}) => {atom1->get + 2})
```
")
@module("./wrapper")
external makeComputedAsync: getValueAsync<'value> => t<'value, Actions.none, [Tags.r]> =
  "atomWrapped"

@ocaml.doc("Create a computed atom that supports read and write.

```rescript
let atom1 = Jotai.Atom.make(1)
let atom2 = Jotai.Atom.makeWritableComputed(
  ({get}) => get(atom1) + 1,
  ({get, set}, arg) => {
    atom1->set(get(atom1) + arg)
  },
)
```
")
@module("./wrapper")
external makeWritableComputed: (
  getValue<'value>,
  setValue<'args>,
) => t<'value, Actions.update<'args>, [Tags.r | Tags.w]> = "atomWrapped"

@ocaml.doc("Create a computed atom with asynchronous write. Jotai supports async write
operations for computed atoms. Simply call 'set' when the promise resolves.

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
")
@module("./wrapper")
external makeWritableComputedAsync: (
  getValue<'value>,
  setValueAsync<'args>,
) => t<'value, Actions.update<'args>, [Tags.r | Tags.w]> = "atomWrapped"

@module("./wrapper")
external _makeWOC: (
  Js.Nullable.t<void>,
  setValue<'args>,
) => t<'value, Actions.update<'args>, [Tags.w]> = "atomWrapped"

@ocaml.doc("Create a writeOnly computed atom.
(Note: Sometimes the type can not be inferred automatically and has to be annotated)

```rescript
let atom1 = make(1)
let atom2: Jotai.Atom.t<int, _, _> = Jotai.Atom.makeWriteOnlyComputed(({get, set}, args) =>
  atom1->set(get(atom1) + args)
)
```
")
let makeWriteOnlyComputed = getSet => _makeWOC(Js.Nullable.null, getSet)

// HOOKS
@ocaml.doc("Standard hook to use with read/write atoms.
(For handling of readOnly/writeOnly atoms see `Jotai.Utils`)

```rescript
let atom1 = Jotai.Atom.make(1)
let (value, setValue) = Jotai.Atom.use(atom1) 
```
")
@module("jotai")
external use: t<'value, Actions.t<'action>, [> Tags.r | Tags.w]> => ('value, 'action) = "useAtom"

type setAtom<'value> = ('value => 'value) => unit
type onUnmount = unit => unit
@ocaml.doc("The `onMount` function will be invoked when the atom is first used in a provider,
and `onUnmount` will be invoked when it's not used.

```rescript
let atom1 = Jotai.Atom.make(1)
atom1->Jotai.Atom.onMount(setAtom => {
  setAtom(a => a + 1) // increment count on mount
  () => () // return onUnmount function
})
```
")
@set
external onMount: (t<'value, _, [> Tags.w]>, setAtom<'value> => onUnmount) => unit = "onMount"

// useUpdateAtom
@ocaml.doc("A hook that returns only the update function of an atom. Can be used to access writeOnly atoms.

```rescript
let atom = Jotai.Atom.make(1)
let setValue = Jotai.Atom.useSetAtom(atom) 
setValue(prev => prev + 1)
```
")
@module("jotai")
external useSetAtom: t<'value, Actions.t<'action>, [> Tags.w]> => 'action =
  "useSetAtom"

// useAtomValue
@ocaml.doc("A hook that returns only the value of an atom. Can be used to access 
readOnly atoms.

```rescript
let atom = Jotai.Atom.make(1)
let value = Jotai.Atom.useAtomValue(atom) 
```
")
@module("jotai")
external useAtomValue: t<'value, _, [> Tags.r]> => 'value = "useAtomValue"

