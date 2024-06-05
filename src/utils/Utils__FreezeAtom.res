/** Creates an atom that is read-only and deeply frozen from an existing atom. 
 */
@module("jotai/utils")
external freezeAtom: Atom.t<'value, 'any, [> Atom.Tags.r]> => Atom.t<
  'value,
  Atom.Actions.none,
  Atom.Tags.r,
> = "freezeAtom"
