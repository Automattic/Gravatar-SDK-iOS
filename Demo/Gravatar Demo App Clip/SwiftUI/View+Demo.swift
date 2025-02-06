import SwiftUI

extension View {
    /// Modify a view with a `ViewBuilder` closure.
    /// Allows us to decide which modifier to apply on runtime.
    func modifier<ModifiedContent: View>(@ViewBuilder body: (Self) -> ModifiedContent) -> some View {
        body(self)
    }
}
