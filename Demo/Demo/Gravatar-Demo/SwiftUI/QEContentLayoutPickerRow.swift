import SwiftUI

struct QEContentLayoutPickerRow: View {
    @Binding var contentLayoutOptions: QELayoutOptions

    var body: some View {
        HStack {
            Text("Content Layout")
            Spacer()
            Picker("Content Layout", selection: $contentLayoutOptions) {
                ForEach(QELayoutOptions.allCases) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
    }
}

#Preview {
    QEContentLayoutPickerRow(contentLayoutOptions: .constant(.verticalExpandable))
}
