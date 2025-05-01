import SwiftUI
import GravatarUI

struct AboutInfoChecklistView: View {
    @Binding var selectedFields: AboutInfoField

    private let allOptions: [(AboutInfoField, String)] = [
        (.displayName, "Display Name"),
        (.aboutMe, "About Me"),
        (.pronunciation, "Pronunciation"),
        (.pronouns, "Pronouns"),
        (.location, "Location"),
        (.jobTitle, "Job Title"),
        (.company, "Company / Organization")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Select Fields")
                .font(.headline)
                .padding(.bottom, 16)
            
            ForEach(allOptions, id: \.0.rawValue) { (field, label) in
                Toggle(isOn: Binding(
                    get: { selectedFields.contains(field) },
                    set: { isOn in
                        if isOn {
                            selectedFields.insert(field)
                        } else {
                            selectedFields.remove(field)
                        }
                    }
                )) {
                    Text(label)
                }
            }
            Spacer()
        }
        .padding()
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var selectedFields: AboutInfoField = []
    AboutInfoChecklistView(selectedFields: $selectedFields)
}
