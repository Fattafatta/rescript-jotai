// PERMISSIONS
@ocaml.doc(" All Jotai functions are scoped to only work with atoms that have
the necessary permissions. An atom can be `#readable`, `#writable` or both.
")
module Permissions = {
  type r = [#readable]
  type w = [#writable]
  type rw = [#readable | #writable]
}

@ocaml.doc("Basic type of all atoms. Each atom has a 'value and a set of 'permissions
that define, which actions are allowed.")
type t<'value, 'permissions> constraint 'permissions = [< Permissions.rw]

type readOnly<'value> = t<'value, Permissions.r>
type readWrite<'value> = t<'value, Permissions.rw>
type writeOnly<'value> = t<'value, Permissions.w>
type readable<'value, 'perm> = t<'value, 'perm> constraint 'perm = [> Permissions.r]
type writable<'value, 'perm> = t<'value, 'perm> constraint 'perm = [> Permissions.w]

// Note: The function signature had to be changed from `'atom => 'value` to
// `{get: 'atom => 'value}`. Wrapping `get` in a record was necessary to handle type
// inference for higher-rank polymorphic functions in ReScript.
// (For details see: https://ocaml.org/manual/polymorphism.html#s%3Ahigher-rank-poly)
type getter = {get: 'value 'perm. readable<'value, 'perm> => 'value}
type setter = {set: 'value 'perm. (writable<'value, 'perm>, 'value) => unit}
type getterAndSetter = {
  get: 'value 'perm. readable<'value, 'perm> => 'value,
  set: 'value 'perm. (writable<'value, 'perm>, 'value) => unit,
}
type getValue<'value> = getter => 'value
type getValueAsync<'value> = getter => Js.Promise.t<'value>
type setValue<'args> = (getterAndSetter, 'args) => unit
type setValueAsync<'args> = (getterAndSetter, 'args) => Js.Promise.t<unit>

// ATOMS
@ocaml.doc("
Create a simple readable and writable atom.

Example:
```
let atom1 = Jotai.Atom.make(1)
let atom2 = Jotai.Atom.make('text')
```
")
@module("jotai")
external make: 'value => readWrite<'value> = "atom"

@ocaml.doc("
Create a computed readonly atom. A computed atom can combine any number
of readable atoms to create a single derived value. 
The syntax varies slightly from Jotai. Note the curly braces in `({get})`.

Example:
```
let atom1 = Jotai.Atom.make(1)
let atom2 = Jotai.Atom.makeComputed(({get}) => get(atom1) + 1)
let atom3 = Jotai.Atom.makeComputed(({get}) => get(atom1) + get(atom2) + 1)
```
")
@module("./wrapper")
external makeComputed: getValue<'value> => readOnly<'value> = "atomWrapped"

@ocaml.doc("
(Requires React.Suspense) Create an async computed readonly atom. All components will
be notified when the returned promise resolves.

Example:
```
let atom1 = Jotai.Atom.make(1)
let atom2 = Jotai.Atom.makeComputedAsync(({get}) => {
  Js.Promise.make((~resolve, ~reject as _) => {
    let count = atom1->get + 1
    Js.Global.setTimeout(() => resolve(. count), 100)->ignore
  })
})
```
")
@module("./wrapper")
external makeComputedAsync: getValueAsync<'value> => readOnly<'value> = "atomWrapped"

@ocaml.doc("
Create a computed atom that supports read and write.

Example:
```
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
external makeWritableComputed: (getValue<'value>, setValue<'args>) => readWrite<'value> =
  "atomWrapped"

@ocaml.doc("
Create a computed atom with asynchronous write. Jotai supports async write operations
for computed atoms. Simply call 'set' when the promise resolves.

Example:
```
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
external makeWritableComputedAsync: (getValue<'value>, setValueAsync<'args>) => readWrite<'value> =
  "atomWrapped"

@module("./wrapper")
external makeWOC: (unit, setValue<'args>) => writeOnly<'value> = "atomWrapped"

@ocaml.doc("
Create a writeOnly computed atom.
(Note:The type can not be inferred automatically so it
has to be annotated)

Example:
```
let atom1 = make(1)
let atom2: Jotai.Atom.writeOnly<int> = Jotai.Atom.makeWriteOnlyComputed(({get, set}, args) =>
  atom1->set(get(atom1) + args)
)
```
")
let makeWriteOnlyComputed = getSet => makeWOC((), getSet)

// HOOKS
@ocaml.doc("Standard hook to use with read/write atoms.
(For handling of readOnly/writeOnly atoms see `Jotai.Utils`)

Example:
```
let atom1 = Jotai.Atom.make(1)
let (value, setValue) = Jotai.Atom.use(atom1) 
```
")
@module("jotai")
external use: readWrite<'value> => ('value, 'value => unit) = "useAtom"

// @module("jotai")
// external useR: t<'value, [> Permissions.r]> => ('value, 'value => unit) = "useAtom"

// @module("jotai")
// external useW: t<'value, Permissions.w> => (unit, 'value => unit) = "useAtom"

// let useReadable = (atom: t<'value, [> Permissions.r]>): 'value => {
//   let (value, _) = atom->useR
//   value
// }

// let useWriteOnly = (atom: t<'value, Permissions.w>) => {
//   let (_, setValue) = atom->useW
//   setValue
// }

type setAtom<'value> = ('value => 'value) => unit
type onUnmount = unit => unit
@ocaml.doc("The `onMount` function will be invoked when the atom is first used in a provider,
and `onUnmount` will be invoked when it's not used.

Example:
```
let atom1 = Jotai.Atom.make(1)
atom1->Jotai.Atom.onMount(setAtom => {
  setAtom(a => a + 1) // increment count on mount
  () => () // return onUnmount function
})
```
")
@module("./wrapper")
external onMount: (writable<'value, 'perm>, setAtom<'value> => onUnmount) => unit = "onMount"
