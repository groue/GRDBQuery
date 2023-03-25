import SwiftUI

// See Documentation.docc/Extensions/QueryObservation.md
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
