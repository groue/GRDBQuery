import SwiftUI

/// A `QueryObservation` controls when `@Query` property wrappers are observing
/// their requests.
///
/// By default, `@Query` observes its request for the whole duration of the
/// presence of the view in the SwiftUI engine.
///
/// You can spare resources by stopping request observation when views are not
/// on screen.
///
/// If you imagine a timeline of view events:
///
///        Initial rendering
///        |        onAppear         onAppear
///        |        |    onDisappear |      onDisappear
///        |        |    |           |      |
///        •--------•----•-----------•------•--------> time
///
/// The `View.queryObservation(_:)` method enables request observation in the
/// chosen time intervals, for all `@Query` property wrappers embedded in
/// the view:
///
/// ```swift
/// // •********•****•***********•******•********* .always
/// MyView().queryObservation(.always)
///
/// // •********•****•-----------•******•--------- .onRender
/// MyView().queryObservation(.onRender)
///
/// // •--------•****•-----------•******•--------- .onAppear
/// MyView().queryObservation(.onAppear)
/// ```
///
/// The default is `.always`.
///
/// Only `.onRender` and `.always` have `@Query` feed a view on its
/// initial rendering.
///
/// For more precise control of the request observation, do not use
/// `View.queryObservation(_:)`, and deal manually with the
/// `\.queryObservationEnabled` environment key instead:
///
/// ```swift
/// // Disables observation
/// MyView().environment(\.queryObservationEnabled, false)
/// ```
public enum QueryObservation {
    /// Requests are always observed.
    case always
    
    /// Request observation starts on the first rendering of the view, and is
    /// later stopped and restarted according to the `onAppear` and
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
    /// If you imagine a timeline of view events:
    ///
    ///     Initial rendering
    ///     |        onAppear         onAppear
    ///     |        |    onDisappear |      onDisappear
    ///     |        |    |           |      |
    ///     •--------•----•-----------•------•--------> time
    ///
    /// Then `queryObservation(_:)` can enable observation in the chosen
    /// time intervals:
    ///
    ///     •********•****•***********•******•********* .always
    ///     •********•****•-----------•******•--------- .onRender
    ///     •--------•****•-----------•******•--------- .onAppear
    ///
    /// The default is `.always`. Only `.onRender` and `.always` have `@Query`
    /// feed your views on the initial rendering.
    @ViewBuilder public func queryObservation(_ queryObservation: QueryObservation) -> some View {
        Group {
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
