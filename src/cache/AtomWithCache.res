/**
```typescript
type Options = {
    size?: number;
    shouldRemove?: (createdAt: CreatedAt, value: AnyAtomValue, map: Map<AnyAtom, AnyAtomValue>) => boolean;
    areEqual?: <V>(a: V, b: V) => boolean;
};
```
 */
type atomWithCacheOpt<'value> = {
  size?: int,
  shouldRemove?: (
    float,
    unknown,
    Js.Map.t<Atom.t<unknown, Atom.Actions.none, [Atom.Tags.r]>, unknown>,
  ) => bool,
  areEqual?: ('value, 'value) => bool,
}

/** Create a read-only atom with cache from a function. The function can be async.

Options:
size (optional): maximum size of cache items.
shouldRemove (optional): a function to check if cache items should be removed.
areEqual (optional): a function to compare atom values.

```rescript
let atom1 = Jotai.AtomWithCache.make(async ({get}) => 1, ~options={size: 5, areEqual=(v1, v2) => v1 == v2})
```
*/
@module("./wrapper")
external make: (
  Atom.getValue<'value>,
  ~options: atomWithCacheOpt<'value>=?,
) => Atom.t<'value, Atom.Actions.none, [Atom.Tags.r]> = "atomWithCacheWrapped"
