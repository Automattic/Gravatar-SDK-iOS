import SwiftUI

struct ImageTemplatesHorizontalGrid: View {
    @ObservedObject var templatesViewModel: TemplatesViewModel

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: .DS.Padding.half) {
                ForEach(templatesViewModel.templates, id: \.self) { template in
                    Button {
                        if let index = templatesViewModel.templates.firstIndex(of: template) {
                            templatesViewModel.selectedTemplateIndex = index
                        }
                    } label: {
                        GridItemCanvasView(imageTemplate: template)
                            .frame(width: 100, height: 100)
                    }
                }
            }
        }
        .padding(.horizontal, .DS.Padding.double)
        .padding(.bottom, .DS.Padding.double)
        // .frame(maxWidth: .infinity, maxHeight: .infinity) // ✅ Important for UIKit embedding
    }
}

#Preview {
    HStack {
        ImageTemplatesHorizontalGrid(templatesViewModel: TemplatesViewModel(originalImage: UIImage()))
    }
}
