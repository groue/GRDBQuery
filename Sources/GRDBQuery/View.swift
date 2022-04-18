import SwiftUI

extension View {
    /// Sets the providing bindings to true when this view appears, and to
    /// false when this view disappears.
    public func mirrorAppearanceState(to bindings: Binding<Bool>...) -> some View {
        self
            .onAppear {
                for binding in bindings {
                    binding.wrappedValue = true
                }
            }
            .onDisappear {
                for binding in bindings {
                    binding.wrappedValue = false
                }
            }
    }
}
