/** A Provider works just like React context provider. If you don't use a 
Provider, it works as provider-less mode with a default store. A Provider will
be necessary if we need to hold different atom values for different component
trees. The store property is optional.

```rescript
let store = Jotai.Store.make()

module App = {
  @react.component
  let make = () =>
    <Jotai.Provider store={store}>
      ...
    </Jotai.Provider>
}
```
*/
@module("jotai")
@react.component
external make: (~children: React.element, ~store: Store.t=?) => React.element = "Provider"
