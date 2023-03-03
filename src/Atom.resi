module Tags: {
  type r = [#readable]
  type w = [#writable]
  type p = [#primitive]
  type re = [#resettable]
  type all = [#primitive | #readable | #resettable | #writable]
}
type none

module Actions: {
  type t<'action>
  type set<'value> = t<('value => 'value) => unit>
  type update<'value> = t<'value => unit>
  type dispatch<'action> = t<'action => unit>
  type none = t<none>
}

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
@module("jotai")
external make: 'value => t<'value, Actions.set<'value>, [Tags.r | Tags.w | Tags.p]> = "atom"
@module("jotai")
external makeAsync: (unit => promise<'value>) => t<
  'value,
  Actions.set<'value>,
  [Tags.r | Tags.w | Tags.p],
> = "atom"
let makeComputed: getValue<'value> => t<'value, Actions.none, Tags.r>
let makeComputedAsync: getValueAsync<'value> => t<'value, Actions.none, Tags.r>
let makeWritableComputed: (
  getValue<'value>,
  setValue<'args>,
) => t<'value, Actions.update<'args>, [Tags.r | Tags.w]>
let makeWritableComputedAsync: (
  getValue<'value>,
  setValueAsync<'args>,
) => t<'value, Actions.update<'args>, [#readable | #writable]>
let makeWriteOnlyComputed: setValue<'a> => t<'b, Actions.update<'a>, Tags.w>
@module("jotai")
external use: t<'value, Actions.t<'action>, [> Tags.r | Tags.w]> => ('value, 'action) = "useAtom"
type setAtom<'value> = ('value => 'value) => unit
type onUnmount = unit => unit
let onMount: (t<'value, _, [> Tags.w]>, setAtom<'value> => onUnmount) => unit
