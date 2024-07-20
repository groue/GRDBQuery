# ``GRDBQuery/QueryObservation``

A `QueryObservation` controls when `@Query` property wrappers are observing
their requests.

## Overview

By default, `@Query` observes its ``Queryable`` request for the whole duration of the presence of the view in the SwiftUI engine: it subscribes to the request before the first `body` rendering, and cancels the subscription when the view is no longer rendered.

You can spare resources by stopping request observation when views are not on screen, with the `View.queryObservation(_:)` method. It enables request observation in the chosen time intervals, for all `@Query` property wrappers embedded in the view.

Given this general timeline of SwiftUI events:

    Initial body rendering
    |    onAppear              onAppear
    |    |         onDisappear |         onDisappear
    |    |         |           |         |      End
    |    |         |           |         |      |
    •----•---------•-----------•---------•------•--> time

- Use `.always` (the default) for subscribing before the first `body` rendering, until the view leaves the SwiftUI engine:

    ```swift
    // Initial body rendering                      End
    // |                                           |
    // <···········································>
    // •----•---------•-----------•---------•------•--> time
    MyView().queryObservation(.always)
    ```

- Use `.onRender` for subscribing before the first `body` rendering, and then using the `onDisappear` and `onAppear` SwiftUI events for pausing the subscription:

    ```swift
    // Initial body rendering
    // |              onDisappear onAppear  onDisappear
    // |              |           |         |
    // <··············>           <·········>
    // •----•---------•-----------•---------•------•--> time
    MyView().queryObservation(.onRender)
    ```

- Use `.onAppear` for letting the `onDisappear` and `onAppear` SwiftUI events control the subscription duration:

    ```swift
    //      onAppear  onDisappear onAppear  onDisappear
    //      |         |           |         |
    //      <·········>           <·········>
    // •----•---------•-----------•---------•------•--> time
    MyView().queryObservation(.onAppear)
    ```

> Note: Only `.onRender` and `.always` have `@Query` feed a view on its initial `body` rendering. This avoids SwiftUI animations for the initial rendering of database values.

> Note: When the request does not publish its initial value right on subscription, `.onRender` and `.onAppear` will have your view display obsolete database values when they re-appear.
>
> By default, a convenience ``ValueObservationQueryable``, ``PresenceObservationQueryable``, or ``FetchQueryable`` type does publish its value right on subscription.

> Tip: For *fast and immediate* database publishers that publish their initial value right on subscription, `QueryObservation.always` and `.onRender` should fit most application needs.

> Tip: For *slow and asynchronous* database publishers that publish all their values asynchronously, prefer `QueryObservation.always`, in order to reduce the probability that the application user can see obsolete database values.
>
> When you use a convenience ``ValueObservationQueryable``, ``PresenceObservationQueryable``, or ``FetchQueryable`` request, you opt in for such an asynchronous publishers with the ``QueryableOptions/async`` option.
>
> You can also consider using `.onAppear` and a plain ``Queryable`` type that prepends its publisher with a sentinel value. This value will allow the view to display a loading indicator instead of obsolete database values, whenever the view appears or re-appears.

When the built-in strategies do not fit the needs of your application, do not use `View.queryObservation(_:)`. Instead, deal directly with the `\.queryObservationEnabled` environment key:

```swift
// Disables observation
MyView().environment(\.queryObservationEnabled, false)

// Enables observation
MyView().environment(\.queryObservationEnabled, true)
```
