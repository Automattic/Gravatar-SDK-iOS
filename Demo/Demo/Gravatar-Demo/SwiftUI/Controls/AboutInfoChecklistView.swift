import SwiftUI
import GravatarUI

struct AboutInfoChecklistView: View {
    typealias FieldOption = (field: AboutInfoField, String)
    @Binding var selectedFields: AboutInfoField

    private let allOptions: [String: [FieldOption]] = [
        "1. Personal": [
            (.displayName, "Display Name"),
            (.aboutMe, "About Me"),
            (.pronunciation, "Pronunciation"),
            (.pronouns, "Pronouns"),
            (.location, "Location"),
        ],
        "2. Professional": [
            (.jobTitle, "Job Title"),
            (.company, "Company / Organization"),
        ],
        "3. Extra": [
            (.firstName, "First Name"),
            (.lastName, "Last Name"),
        ]
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Select Fields")
                .font(.headline)
                .padding(.bottom, 16)

            ForEach(Array(allOptions).sorted(by: { $0.key < $1.key }), id: \.key) { (groupName, fields) in
                Text(groupName)
                    .font(.headline)
                    .padding()
                ForEach(fields, id: \.field.rawValue) { (field, label) in
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
