// // atomWithStorage
// @module("jotai/utils")
// external atomWithStorage: (string, 'value) => Atom.readWrite<'value> = "atomWithStorage"

// // atomWithReset
// @module("jotai/utils")
// external atomWithReset: 'value => Resettable.t<'value> = "atomWithReset"

// // atomWithDefault
// @module("jotai/utils")
// external atomWithDefault: Atom.getValue<'value> => Resettable.t<'value> = "atomWithDefault"

// // atomWithReducer
// @module("jotai/utils")
// external atomWithReducer: ('value, reducer<'value, 'action>) => withReducer<'value> =
//   "atomWithReducer"

module AtomWithStorage = Utils_AtomWithStorage

module AtomWithDefault = Utils_AtomWithDefault

module AtomWithReset = Utils_AtomWithReset

module AtomWithReducer = Utils_AtomWithReducer

module Resettable = Utils_Resettable

include Utils__Hooks

// TODO: Add missing utils
// - atomWithObservable
// - atomWithHash
// - atomFamily
// - selectAtom
// - useAtomCallback
// - freezeAtom
// - splitAtom
// - waitForAll
// - useHydrateAtoms
