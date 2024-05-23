open Jest
open Expect
open TestingLibrary.React

@val external window: 'w = "window"

test("AtomWithStorage", () => {
  let a = Utils.AtomWithStorage.make("mykey", 1)
  let {result} = renderHook(() => Atom.use(a))
  let (value, setValue) = result.current
  expect(value)->toBe(1)
  act(() => setValue(p => p + 1))
  let fromStorage =
    window["localStorage"]["getItem"]("mykey")->Belt.Int.fromString->Belt.Option.getUnsafe
  expect(fromStorage)->toBe(2)
})

test("AtomWithDefault", () => {
  let a = Atom.make(1)
  let b = Utils.AtomWithDefault.make(({get}) => a->get + 1)
  let {result} = renderHook(() => Atom.use(b))
  let (value, setValue) = result.current
  expect(value)->toBe(2)
  act(() => setValue(_ => 1))
  let (value, _) = result.current
  expect(value)->toBe(1)
  let {result} = renderHook(() => Utils.useResetAtom(b))
  act(() => result.current())
  let {result} = renderHook(() => Atom.use(b))
  let (value, _) = result.current
  expect(value)->toBe(2)
})

test("AtomWithReset", () => {
  let a = Utils.AtomWithReset.make(1)
  let {result} = renderHook(() => Atom.use(a))
  let (value, setValue) = result.current
  expect(value)->toBe(1)
  act(() => setValue(p => p + 1))
  let (value, _) = result.current
  expect(value)->toBe(2)
  let {result} = renderHook(() => Utils.useResetAtom(a))
  act(() => result.current())
  let {result} = renderHook(() => Atom.use(a))
  let (value, _) = result.current
  expect(value)->toBe(1)
})

type actionType = Inc(int) | Dec(int)

test("AtomWithReducer", () => {
  let countReducer = (prev, action) => {
    switch action {
    | Inc(num) => prev + num
    | Dec(num) => prev - num
    }
  }
  let a = Utils.AtomWithReducer.make(0, countReducer)
  let {result} = renderHook(() => Atom.use(a))
  let (value, dispatch) = result.current
  expect(value)->toBe(0)
  act(() => Inc(1)->dispatch)
  let (value, _) = result.current
  expect(value)->toBe(1)
})

test("SelectAtom", () => {
  let a = Atom.make(1)
  let b = Utils.SelectAtom.make(a, (a, _prev) => a + 1)
  let {result: resultA} = renderHook(() => Atom.use(a))
  let (_, setValue) = resultA.current
  let {result} = renderHook(() => Atom.useAtomValue(b))
  expect(result.current)->toBe(2)
  act(() => setValue(_ => 2))

  // The following lines should not compile because `b` is not writable
  // let _ = renderHook(() => Atom.useAtom(b))
  // let _ = renderHook(() => Atom.useSetAtom(b))

  expect(result.current)->toBe(3)
})

test("useReducerAtom hook", () => {
  let countReducer = (prev, action) => {
    switch action {
    | Inc(num) => prev + num
    | Dec(num) => prev - num
    }
  }
  let a = Atom.make(1)
  let {result} = renderHook(() => Utils.useReducerAtom(a, countReducer))
  let (value, dispatch) = result.current
  expect(value)->toBe(1)
  act(() => Inc(1)->dispatch)
  let (value, _) = result.current
  expect(value)->toBe(2)
})

test("useUpdateAtom hook", () => {
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
