open Jest
open Expect
open TestingLibrary.React

test("standard atom", () => {
  let a = Atom.make(1)
  let {result} = renderHook(() => Atom.use(a))
  let (value, setValue) = result.current

  expect(value)->toBe(1)

  act(() => setValue(p => p + 1))
  let (value, _) = result.current
  expect(value)->toBe(2)
})

// test("async read atom", () => {
//   act(() =>{
//     let a = Atom.makeAsync(async () => {1})
//     let {result} = renderHook(() => Atom.use(a))
//     let (value, _) = result.current

//     expect(value)->toBe(1)
//   })
// })

test("computed readonly atom", () => {
  let a = Atom.make(1)
  let c = Atom.makeComputed(({get}) => get(a) + 1)
  let {result: r1} = renderHook(() => Atom.use(a))
  let {result: r2} = renderHook(() => Atom.useAtomValue(c))

  expect(r2.current)->toBe(2)
  let (_, setValue) = r1.current

  act(() => setValue(p => p + 1))
  expect(r2.current)->toBe(3)
})

test("computed writable atom", () => {
  let a = Atom.make(1)
  let rw = Atom.makeWritableComputed(
    ({get}) => a->get + 1,
    ({get, set}, arg) => {
      a->set(a->get + arg)
    },
  )
  let {result} = renderHook(() => Atom.use(rw))
  let (value, addValue) = result.current
  expect(value)->toBe(2)

  act(() => addValue(1))
  let (value, _) = result.current
  expect(value)->toBe(3)
})

// testPromise("async readonly atom", async () => {
//   let a = Atom.make(1)
//   let c = Atom.makeComputedAsync(({get}) => Js.Promise.resolve(get(a) + 1))
//   act(() => {
//     let {result} = renderHook(() => Atom.useAtomValue(c), ())
//     t->equal(result.current, 2, "should be 2")
//   })
//   done()
// })

test("computed writeonly atom", () => {
  let a = Atom.make(1)
  let b: Atom.t<int, _, _> = Atom.makeWriteOnlyComputed(({set, _}, id) => {
    a->set(id)
  })
  let {result} = renderHook(() => Atom.useSetAtom(b))
  let setValue = result.current
  act(() => setValue(2))
  let {result} = renderHook(() => Atom.use(a))
  let (value, _) = result.current
  expect(value)->toBe(2)
})

test("useSetAtom hook", () => {
  let a = Atom.make(1)
  let {result} = renderHook(() => Atom.useSetAtom(a))
  let setValue = result.current
  act(() => setValue(p => p + 1))
  let {result} = renderHook(() => Atom.use(a))
  let (value, _) = result.current
  expect(value)->toBe(2)
})

test("useAtomValue hook", () => {
  let a = Atom.make(1)
  let {result} = renderHook(() => Atom.use(a))
  let (_, setValue) = result.current
  act(() => setValue(p => p + 1))
  let {result} = renderHook(() => Atom.useAtomValue(a))
  expect(result.current)->toBe(2)
})

test("debugLabel", () => {
  let a = Atom.make(1)
  Atom.debugLabel(a, "a")
  expect(a)->toHavePropertyValue("debugLabel", "a")
})
