open Zora
open ZoraJsdom
open RescriptHooksTestingLibrary.Testing

zoraWithDOM("standard atom", t => {
  let a = Atom.make(1)
  let {result} = renderHook(() => Atom.use(a), ())
  let (value, setValue) = result.current
  t->equal(value, 1, "should be 1")
  act(() => setValue(p => p + 1))
  let (value, _) = result.current
  t->equal(value, 2, "should be 2")
  done()
})

zoraWithDOM("computed readonly atom", t => {
  let a = Atom.make(1)
  let c = Atom.makeComputed(({get}) => get(a) + 1)
  let {result: r1} = renderHook(() => Atom.use(a), ())
  let {result: r2} = renderHook(() => Utils.useAtomValue(c), ())
  t->equal(r2.current, 2, "should be 2")
  let (_, setValue) = r1.current
  act(() => setValue(p => p + 1))
  t->equal(r2.current, 3, "should be 3")
  done()
})

zoraWithDOM("computed writable atom", t => {
  let a = Atom.make(1)
  let rw = Atom.makeWritableComputed(
    ({get}) => a->get + 1,
    ({get, set}, arg) => {
      a->set(a->get + arg)
    },
  )
  let {result} = renderHook(() => Atom.use(rw), ())
  let (value, addValue) = result.current
  t->equal(value, 2, "should be 2")
  act(() => addValue(1))
  let (value, _) = result.current
  t->equal(value, 3, "should be 3")
  done()
})

// zora("async readonly atom", t => {
//   let a = Atom.make(1)
//   let c = Atom.makeComputedAsync(({get}) => Js.Promise.resolve(get(a) + 1))
//   act(() => {
//     let {result} = renderHook(() => Utils.useAtomValue(c), ())
//     t->equal(result.current, 2, "should be 2")
//   })
//   done()
// })


zoraWithDOM("computed writeonly atom", t => {
  let a = Atom.make(1)
  let b: Atom.t<int, _, _> = Atom.makeWriteOnlyComputed(
  ({set, _}, id) => {
    a->set(id)
  })
  let {result} = renderHook(() => Utils.useUpdateAtom(b), ())
  let setValue = result.current
  act(() => setValue(2))
  let {result} = renderHook(() => Atom.use(a), ())
  let (value, _) = result.current
  t->equal(value, 2, "should be 2")
  done()
})