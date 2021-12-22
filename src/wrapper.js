const { atom } = require('jotai');
const { atomWithDefault } = require('jotai/utils')

/**
 * The compiler stores a funcion type at time of definition and not application.
 * This can result in problems when using higher-rank polymorphic functions. Ocaml
 * provides two ways of handling these scenarios, and luckily they work in ReScript too.
 * We use "universally quantified record fields" here. To accoplish this, the 'get' and 'set' functions
 * are wrapped in a record.
 * (See: https://ocaml.org/manual/polymorphism.html#s%3Ahigher-rank-poly)
 * @param {*} getFunc 
 * @param {*} writeFunc 
 * @returns 
 */
exports.atomWrapped = (getFunc, writeFunc) => {
  return atom(
    (get) => {
      return getFunc({ get });
    },
    (get, set, args) => {
      // TODO The get function used by Jotai is of type WriteGetter that has an optional parameter
      // that is only used internally. But it messes up the Curry._1 function used by rescript. Keeping the
      // optional parameter would make the function signature unnecessarily complex.
      const getWithoutOptions = a => get(a, undefined);
      writeFunc({ get: getWithoutOptions, set, dispatch: set }, args);
    },
  );
};

exports.onMount = (anAtom, setter) => {
  anAtom.onMount = setter
}
exports.something = undefined

exports.atomWithDefaultWrapped = (getFunc) => {
  return atomWithDefault(
    (get) => {
      return getFunc({ get });
    }
  );
};
