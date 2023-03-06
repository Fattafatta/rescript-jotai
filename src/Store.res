type t

@module("jotai")
external make: unit => t = "createStore"

@module("jotai")
external getDefaultStore: unit => t = "getDefaultStore"

type unitToUnitFunc = unit => unit
type get<'value, 'action, 'tags> = Atom.t<'value, 'action, 'tags> => 'value
type set<'value, 'action, 'tags> = (Atom.t<'value, 'action, 'tags>, 'value) => unit
type sup<'value, 'action, 'tags> = (
  Atom.t<'value, 'action, 'tags>,
  unitToUnitFunc,
) => unitToUnitFunc

@get external get: t => get<'value, _, _> = "get"

@get external set: t => set<'value, _, _> = "set"

@get external sub: t => sup<_, _, _> = "sub"

@module("Jotai")
external use: unit => t = "useStore"
