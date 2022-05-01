import SwiftUI

/// A `QueryObservation` controls when `@Query` property wrappers are observing
/// their requests.
///
/// By default, `@Query` observes its ``Queryable`` request for the whole
/// duration of the presence of the view in the SwiftUI engine: it subscribes
/// to the request publisher before the first `body` rendering, and cancels the
/// subscription when the view is no longer rendered.
///
/// You can spare resources by stopping request observation when views are not
/// on screen, with the `View.queryObservation(_:)` method. It enables request
/// observation in the chosen time intervals, for all `@Query` property wrappers
/// embedded in the view.
///
/// Given this general timeline of SwiftUI events:
///
///     Initial body rendering
///     |    onAppear              onAppear
///     |    |         onDisappear |         onDisappear
///     |    |         |           |         |      End
///     |    |         |           |         |      |
///     •----•---------•-----------•---------•------•--> time
///
/// - Use `.always` (the default) for subscribing before the first `body`
///   rendering, until the view leaves the SwiftUI engine:
///
///     ```swift
///     // Initial body rendering                      End
///     // |                                           |
///     // <···········································>
///     // •----•---------•-----------•---------•------•--> time
///     MyView().queryObservation(.always)
///     ```
///
/// - Use `.onRender` for subscribing before the first `body` rendering, and
///   then using the `onDisappear` and `onAppear` SwiftUI events for pausing
///   the subscription:
///
///     ```swift
///     // Initial body rendering
///     // |              onDisappear onAppear  onDisappear
///     // |              |           |         |
///     // <··············>           <·········>
///     // •----•---------•-----------•---------•------•--> time
///     MyView().queryObservation(.onRender)
///     ```
///
/// - Use `.onAppear` for letting the `onDisappear` and `onAppear` SwiftUI
///   events control the subscription duration:
///
///     ```swift
///     //      onAppear  onDisappear onAppear  onDisappear
///     //      |         |           |         |
///     //      <·········>           <·········>
///     // •----•---------•-----------•---------•------•--> time
///     MyView().queryObservation(.onAppear)
///     ```
///
/// > Note: Only `.onRender` and `.always` have `@Query` feed a view on its
/// > initial `body` rendering. This avoids SwiftUI animations for the initial
/// > rendering of database values.
///
/// > Note: Unless the request publisher publishes its initial value right on
/// > subscription, `.onRender` and `.onAppear` will have your view display
/// > obsolete database values when they re-appear. See <doc:GettingStarted>
/// > for more information about _immediate_ database publishers.
///
/// > Tip: For *fast and immediate* database publishers that publish their
/// > initial value right on subscription, `QueryObservation.always` and
/// > `.onRender` should fit most application needs.
///
/// > Tip: For *slow and asynchronous* database publishers that publish all
/// > their values asynchronously, prefer `QueryObservation.always`, in order to
/// > reduce the probability that the application user can see obsolete
/// > database values.
/// >
/// > You can also consider using `.onAppear`, and prepending your request
/// > publisher with a sentinel value that will allow your view to display a
/// > loading indicator instead of obsolete database values, when the view
/// > appears or re-appears.
///
/// When the built-in strategies do not fit the needs of your application, do
/// not use `View.queryObservation(_:)`. Instead, deal directly with the
/// `\.queryObservationEnabled` environment key:
///
/// ```swift
/// // Disables observation
/// MyView().environment(\.queryObservationEnabled, false)
///
/// // Enables observation
/// MyView().environment(\.queryObservationEnabled, true)
/// ```
public enum QueryObservation {
    /// Requests are always observed.
    case always
    
    /// Request observation starts on the first `body` rendering of the view,
    /// and is later stopped and restarted according to the `onAppear` and
    /// `onDisappear` View events.
    case onRender
    
    /// Request observation starts and stops according to the `onAppear` and
    /// `onDisappear` View events.
    case onAppear
}

extension View {
    /// Controls when the `@Query` property wrappers observe their requests,
    /// in this view.
    ///
    /// See ``QueryObservation`` for a complete discussion.
    @ViewBuilder public func queryObservation(_ queryObservation: QueryObservation) -> some View {
        switch queryObservation {
        case .always:
            self.environment(\.queryObservationEnabled, true)
        case .onRender:
            QueryObservationWrapper(queryObservationEnabled: true, content: self)
        case .onAppear:
            QueryObservationWrapper(queryObservationEnabled: false, content: self)
        }
    }
}

private struct QueryObservationWrapper<Content: View>: View {
    @State var queryObservationEnabled: Bool
    var content: Content
    
    var body: some View {
        content
            .environment(\.queryObservationEnabled, queryObservationEnabled)
            .onAppear {
                queryObservationEnabled = true
            }
            .onDisappear {
                queryObservationEnabled = false
            }
    }
}
