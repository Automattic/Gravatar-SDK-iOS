import SwiftUI

struct ImageTemplatesHorizontalGrid: View {
    @ObservedObject var templatesViewModel: TemplatesViewModel

    var body: some View {
        Text("CanvasTemplatesHorizontalGrid")
        ScrollView(.horizontal) {
            HStack(spacing: .DS.Padding.half) {
                ForEach(templatesViewModel.templates, id: \.self) { _ in
                }
            }
        }
        .padding(.horizontal, .DS.Padding.double)
        .padding(.bottom, .DS.Padding.double)
    }
}

#Preview {
    ImageTemplatesHorizontalGrid(templatesViewModel: TemplatesViewModel())
}
