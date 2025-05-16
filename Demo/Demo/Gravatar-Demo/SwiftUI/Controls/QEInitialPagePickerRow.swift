import SwiftUI
import GravatarUI

struct QEInitialPagePickerRow: View {
    @Binding var initialPage: InitialPage

    var body: some View {
        HStack {
            Text("Initial Page")
            Spacer()
            Picker("Initial Page", selection: $initialPage) {
                ForEach(InitialPage.allCases) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
    }
}

enum InitialPage: String, CaseIterable, Identifiable {
    var id: String {
        self.rawValue
    }

    case avatarPicker = "Avatar Picker"
    case aboutEditor = "About Editor"

    func map() -> AvatarPickerAndAboutEditorConfiguration.Page {
        switch self {
        case .aboutEditor: .aboutEditor
        case .avatarPicker: .avatarPicker
        }
    }
}
