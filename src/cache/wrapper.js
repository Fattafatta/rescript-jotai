const { atomWithCache } = require("jotai-cache");

const wrapper = (atom) => {
  /**
   * The compiler stores a function type at time of definition and not application.
   * This can result in problems when using higher-rank polymorphic functions. Ocaml
   * provides two ways of handling these scenarios, and luckily they work in ReScript too.
   * We use "universally quantified record fields" here. To accomplish this, the 'get' and 'set' functions
   * are wrapped in a record.
   * (See: https://ocaml.org/manual/polymorphism.html#s%3Ahigher-rank-poly)
   * @param {*} getFunc
   * @param {*} options
   * @returns an atom config
   */
  return (getFunc, options) => {
    return atom(
      (get) => {
        return getFunc({ get });
      },
      options
    );
  };
};

exports.atomWithCacheWrapped = wrapper(atomWithCache);