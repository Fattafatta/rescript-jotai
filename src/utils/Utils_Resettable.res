// TODO: Find a better way to handle resettable atoms that do not require the
// `Resettable.unpack` function.

type t<'value> = Atom.readWrite<'value>
let unpack = r => r
