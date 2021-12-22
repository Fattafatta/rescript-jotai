open Zora
open ZoraJsdom
open RescriptHooksTestingLibrary.Testing

@val external window: 'w = "window"

zoraWithDOM("AtomWithStorage", t => {
  let a = Utils.AtomWithStorage.make("mykey", 1)
  let {result} = renderHook(() => Atom.use(a), ())
  let (value, setValue) = result.current
  t->equal(value, 1, "should be 1")
  act(() => setValue(p => p + 1))
  let fromStorage =
    window["localStorage"]["getItem"]("mykey")->Belt.Int.fromString->Belt.Option.getUnsafe
  t->equal(fromStorage, 2, "localStorage should be 2")
  done()
})

zoraWithDOM("AtomWithDefault", t => {
  let a = Atom.make(1)
  let b = Utils.AtomWithDefault.make(({get}) => a->get + 1)
  let {result} = renderHook(() => Atom.use(b), ())
  let (value, setValue) = result.current
  t->equal(value, 2, "should be 2")
  act(() => setValue(_ => 1))
  let (value, _) = result.current
  t->equal(value, 1, "should be 1 after update")
  let {result} = renderHook(() => Utils.useResetAtom(b), ())
  result.current()
  let {result} = renderHook(() => Atom.use(b), ())
  let (value, _) = result.current
  t->equal(value, 2, "should be 2 again after reset")
  done()
})

zoraWithDOM("AtomWithReset", t => {
  let a = Utils.AtomWithReset.make(1)
  let {result} = renderHook(() => Atom.use(a), ())
  let (value, setValue) = result.current
  t->equal(value, 1, "should be 1")
  act(() => setValue(p => p + 1))
  let (value, _) = result.current
  t->equal(value, 2, "should be 2 after update")
  let {result} = renderHook(() => Utils.useResetAtom(a), ())
  result.current()
  let {result} = renderHook(() => Atom.use(a), ())
  let (value, _) = result.current
  t->equal(value, 1, "should be 1 again after reset")
  done()
})

type actionType = Inc(int) | Dec(int)

zoraWithDOM("AtomWithReducer", t => {
  let countReducer = (prev, action) => {
    switch action {
    | Inc(num) => prev + num
    | Dec(num) => prev - num
    }
  }
  let a = Utils.AtomWithReducer.make(0, countReducer)
  let {result} = renderHook(() => Atom.use(a), ())
  let (value, dispatch) = result.current
  t->equal(value, 0, "should be 0")
  act(() => Inc(1)->dispatch)
  let (value, _) = result.current
  t->equal(value, 1, "should be 1 after update")
  done()
})

zoraWithDOM("useReducerAtom hook", t => {
  let countReducer = (prev, action) => {
    switch action {
    | Inc(num) => prev + num
    | Dec(num) => prev - num
    }
  }
  let a = Atom.make(1)
  let {result} = renderHook(() => Utils.useReducerAtom(a, countReducer), ())
  let (value, dispatch) = result.current
  t->equal(value, 1, "should be 1")
  act(() => Inc(1)->dispatch)
  let (value, _) = result.current
  t->equal(value, 2, "should be 2 after update")
  done()
})

zoraWithDOM("useUpdateAtom hook", t => {
  let a = Atom.make(1)
  let {result} = renderHook(() => Utils.useUpdateAtom(a), ())
  let setValue = result.current
  act(() => setValue(p => p + 1))
  let {result} = renderHook(() => Atom.use(a), ())
  let (value, _) = result.current
  t->equal(value, 2, "should be 2")
  done()
})

zoraWithDOM("useAtomValue hook", t => {
  let a = Atom.make(1)
  let {result} = renderHook(() => Atom.use(a), ())
  let (_, setValue) = result.current
  act(() => setValue(p => p + 1))
  let {result} = renderHook(() => Utils.useAtomValue(a), ())
  t->equal(result.current, 2, "should be 2")
  done()
})
