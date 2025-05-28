open Atom

type atomWithCacheOpt<'value> = {
  size?: int,
  areEqual?: ('value, 'value) => bool,
}

@module("./wrapper")
external make: (getValue<'value>, ~option: atomWithCacheOpt<'value>=?) => t<'value, Actions.none, [#readable]> = "atomWithCacheWrapped"