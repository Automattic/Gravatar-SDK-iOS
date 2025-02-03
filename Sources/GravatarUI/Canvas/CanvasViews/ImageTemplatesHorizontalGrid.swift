import SwiftUI

struct ImageTemplatesHorizontalGrid: View {
    @ObservedObject var templatesViewModel: TemplatesViewModel

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 0) {
                ForEach(templatesViewModel.templates, id: \.self) { template in
                    Button {
                        if let index = templatesViewModel.templates.firstIndex(of: template) {
                            templatesViewModel.selectedTemplateIndex = index
                        }
                    } label: {
                        GridItemCanvasView(imageTemplate: template)
                            .frame(width: 125, height: 125)
                    }
                    .shape(
                        RoundedRectangle(cornerSize: .init(width: 6, height: 6)),
                        borderColor: .accentColor,
                        borderWidth: templatesViewModel.selectedTemplate?.id == template.id ? 4 : 0
                    )
                    .padding(.horizontal, .DS.Padding.single)
                    .padding(.vertical, .DS.Padding.single)
                }
            }
        }
        .padding(.horizontal, .DS.Padding.double)
        .padding(.vertical, .DS.Padding.double)
        .background(Color.black)
        // .frame(maxWidth: .infinity, maxHeight: .infinity) // ✅ Important for UIKit embedding
    }
}

#Preview {
    HStack {
        ImageTemplatesHorizontalGrid(templatesViewModel: TemplatesViewModel(originalImage: UIImage()))
    }
}
