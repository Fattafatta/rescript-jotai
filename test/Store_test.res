open Jest
open Expect

type actionType = Inc(int) | Dec(int)

describe("Store", () => {
  let store = Store.make()
  let atom = Atom.make(0)

  test("should be able to create a store", () => {
    expect(store)->Expect.toMatchObject({
      "get": ExpectStatic.anything(),
      "set": ExpectStatic.anything(),
      "sub": ExpectStatic.anything(),
    })
  })

  test("should be able to get a value from a store", () => {
    let value = Store.get(store, atom)
    expect(value)->toBe(0)
  })

  test("should be able to set a value to a store", () => {
    Store.set(store, atom, 1)
    let value = store->Store.get(atom)
    expect(value)->toBe(1)
  })

  test("should be able to dispatch an action to the store", () => {
    let atom = Utils.AtomWithReducer.make(
      0,
      (prev, action) => {
        switch action {
        | Inc(num) => prev + num
        | Dec(num) => prev - num
        }
      },
    )
    Store.dispatch(store, atom, Inc(1))
    let value = store->Store.get(atom)
    expect(value)->toBe(1)

    Store.dispatch(store, atom, Dec(1))
    let value = store->Store.get(atom)
    expect(value)->toBe(0)
  })

  test("should be able to update a writable computed", () => {
    let innerAtom = Atom.make(0)
    let atom = Atom.makeWritableComputed(
      ({get}) => get(innerAtom),
      ({get, set}, arg) => {
        set(innerAtom, get(innerAtom) + arg)
      },
    )

    Store.update(store, atom, 1)
    let value = store->Store.get(atom)
    expect(value)->toBe(1)
  })

  let spy = Jest.Mock.make(() => ())
  let callback = Jest.Mock.fn(spy)
  let unsubscribe = store->Store.sub(atom, callback)

  beforeEach(() => {
    Mock.mockReset(spy)
  })

  afterAll(() => {
    unsubscribe()
  })

  test("should be able to subscribe to a store", () => {
    expect(spy)->toBeCalledTimes(0)
    Store.set(store, atom, 2)
    expect(spy)->toBeCalledTimes(1)
  })
})
