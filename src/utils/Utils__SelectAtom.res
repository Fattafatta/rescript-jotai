type t<'slice> = Atom.t<'slice, Atom.Actions.none, Atom.Tags.r>

/** Derives a readonly atom that selects a slice of the state of an atom. 
 */
@module("jotai/utils")
external make: (
  Atom.t<'data, _, [> Atom.Tags.r]>,
  @uncurry ('data, option<'slice>) => 'slice,
) => t<'slice> = "selectAtom"

/** Derives a readonly atom that selects a slice of the state of an atom with a custom equality function.
 */
@module("jotai/utils")
external makeWithEquality: (
  Atom.t<'data, _, [> Atom.Tags.r]>,
  @uncurry ('data, option<'slice>, option<'slice>) => 'slice,
  @uncurry ('slice, 'slice) => bool,
) => t<'slice> = "selectAtom"
