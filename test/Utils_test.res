open Zora
open ZoraJsdom
open RescriptHooksTestingLibrary.Testing

@val external window: 'w = "window"

zoraWithDOM("atom with storage", t => {
  let a = Utils.AtomWithStorage.make("mykey", 1)
  let {result} = renderHook(() => Atom.use(a), ())
  let (value, setValue) = result.current
  t->equal(value, 1, "should be 1")
  act(() => setValue(2))
  let fromStorage =
    window["localStorage"]["getItem"]("mykey")->Belt.Int.fromString->Belt.Option.getUnsafe
  t->equal(fromStorage, 2, "localStorage should be 2")
  done()
})

zoraWithDOM("atom with default", t => {
  let a = Atom.make(1)
  let b = Utils.AtomWithDefault.make(({get}) => a->get + 1)
  let {result} = renderHook(() => Atom.use(b->Utils.Resettable.unpack), ())
  let (value, setValue) = result.current
  t->equal(value, 2, "should be 2")
  act(() => setValue(1))
  let (value, _) = result.current
  t->equal(value, 1, "should be 1 after update")
  let {result} = renderHook(() => Utils.useResetAtom(b), ())
  result.current()
  let {result} = renderHook(() => Atom.use(b->Utils.Resettable.unpack), ())
  let (value, _) = result.current
  t->equal(value, 2, "should be 2 again after reset")
  done()
})
