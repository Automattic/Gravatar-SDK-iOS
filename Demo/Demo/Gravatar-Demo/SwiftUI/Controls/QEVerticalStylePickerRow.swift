import SwiftUI
import GravatarUI

struct SheetStylePickerRow: View {
    @Binding var sheetStyle: SheetPresentationStyle
    @State var verticalStyleRep: SheetPresentationStyleRepresentation = .expandableMedium

    var body: some View {
        HStack {
            Text("Sheet Style")
            Spacer()
            Picker("Vertical Style", selection: $verticalStyleRep) {
                ForEach(SheetPresentationStyleRepresentation.allCases, id: \.self) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .onChange(of: verticalStyleRep) { newValue in
                switch newValue {
                case .large:
                    sheetStyle = .large()
                case .expandableMedium:
                    sheetStyle = .expandableMedium()
                case .expandableMediumPrioritizeScrolling:
                    sheetStyle = .expandableMedium(prioritizeScrollOverResize: true)
                case .intrinsicHeight:
                    sheetStyle = .intrinsicHeight()
                case .automatic:
                    sheetStyle = .automatic()
                case .automaticPrioritizeScrolling:
                    sheetStyle = .automatic(prioritizeScrollOverResize: true)
                }
            }
        }
    }
}
