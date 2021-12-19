module Permissions: {
  type r = [#readable]
  type w = [#writable]
  type rw = [#readable | #writable]
}
type t<'value, 'a> constraint 'a = [< Permissions.rw]
type readOnly<'value> = t<'value, Permissions.r>
type readWrite<'value> = t<'value, Permissions.rw>
type writeOnly<'value> = t<'value, Permissions.w>
type readable<'value, 'perm> = t<'value, 'perm> constraint 'perm = [> Permissions.r]
type writable<'value, 'perm> = t<'value, 'perm> constraint 'perm = [> Permissions.w]
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
@module("jotai")
external make: 'value => readWrite<'value> = "atom"
let makeComputed: getValue<'value> => readOnly<'value>
let makeComputedAsync: getValueAsync<'value> => readOnly<'value>
let makeWritableComputed: (getValue<'value>, setValue<'args>) => readWrite<'value>
let makeWritableComputedAsync: (getValue<'value>, setValueAsync<'args>) => readWrite<'value>
let makeWriteOnlyComputed: setValue<'a> => writeOnly<'b>
@module("jotai")
external use: readWrite<'value> => ('value, 'value => unit) = "useAtom"
type setAtom<'value> = ('value => 'value) => unit
type onUnmount = unit => unit
let onMount: (writable<'value, [< Permissions.w]>, setAtom<'value> => onUnmount) => unit
