open Jest
open Expect
open TestingLibrary.React

let sleep = async ms => {
  await Js.Promise.make((~resolve, ~reject) => Js.Global.setTimeout(resolve, ms)->ignore)
}

testPromise("standard atom with cache", async () => {
  let a = Atom.make(1)
  let c = AtomWithCache.make(async ({get}) => {
    await sleep(200)
    get(a) + 1
  })
  let {result: r1} = renderHook(() => Atom.useAtom(a))
  let {result: r2} = renderHook(() => Atom.useAtomValueAsync(c))
  let (value1, setValue1) = r1.current
  expect(value1)->toBe(1)
  await sleep(250)
  expect(r2.current)->toBe(2)

  act(() => setValue1(_ => 2))
  await sleep(250)
  expect(r2.current)->toBe(3)

  act(() => setValue1(_ => 1))
  await sleep(50)
  expect(r2.current)->toBe(2)
})
