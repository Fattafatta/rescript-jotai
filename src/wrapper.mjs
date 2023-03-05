import { atom } from "jotai";
import { atomWithDefault } from "jotai/utils";

/**
 * The compiler stores a function type at time of definition and not application.
 * This can result in problems when using higher-rank polymorphic functions. Ocaml
 * provides two ways of handling these scenarios, and luckily they work in ReScript too.
 * We use "universally quantified record fields" here. To accomplish this, the 'get' and 'set' functions
 * are wrapped in a record.
 * (See: https://ocaml.org/manual/polymorphism.html#s%3Ahigher-rank-poly)
 * @param {*} getFunc
 * @param {*} writeFunc
 * @returns
 */
const atomWrapped = (getFunc, writeFunc) => {
  return atom(
    (get) => {
      return getFunc({ get });
    },
    (get, set, args) => {
      // TODO The get function used by Jotai is of type WriteGetter that has an optional parameter
      // that is only used internally. But it messes up the Curry._1 function used by rescript. Keeping the
      // optional parameter would make the function signature unnecessarily complex.
      const getWithoutOptions = (a) => get(a, undefined);
      // TODO The original function parameters are defined as (a, ..args). Therefore fn.length = 1. This results in
      // the Curr._2 function applied here to mess up. This function makes sure that the arity is always at least 2.
      const setWithArity2 = (a1, a2, ...args) => {
        set(a1, ...[a2, ...args]);
      };
      writeFunc(
        { get: getWithoutOptions, set: setWithArity2, dispatch: set },
        args
      );
    }
  );
};
/**
 * There is no way to check at compile time, if an atom was created with a function as argument.
 * So a warning is logged instead.
 * @param {*} val
 * @returns an atom config
 */
const atomWarn = (val) => {
  if (typeof val === "function") {
    console.warn(
      "Calling Atom.make with a function as argument is not allowed. Use Atom.makeComputed instead."
    );
  }
  return atom(val);
};

const something = undefined;

const atomWithDefaultWrapped = (getFunc) => {
  return atomWithDefault((get) => {
    return getFunc({ get });
  });
};

export { atomWrapped, atomWithDefaultWrapped, atomWarn, something };
