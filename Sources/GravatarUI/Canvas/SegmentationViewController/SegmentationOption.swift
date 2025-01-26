import UIKit

struct SegmentationOption: Identifiable, Equatable {
    let id = UUID()
    let type: SegmentationType
    let title: String
    let description: String
    let icon: UIImage?

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    static func makeSegmentationOptions() -> [SegmentationOption] {
        SegmentationType.supportedTypes.map { type in
            switch type {
            case .foreground:
                SegmentationOption(
                    type: .foreground,
                    title: SDKLocalizedString(
                        "Foreground",
                        comment: "Suitable for any photo featuring objects, people, or animals in the foreground."
                    ),
                    description: SDKLocalizedString(
                        "Includes the objects or people that are in the foreground.",
                        comment: "Descriptive text about a background removal functionality."
                    ),
                    icon: UIImage(systemName: "person.2.crop.square.stack.fill")
                )
            case .people:
                SegmentationOption(
                    type: .people,
                    title: SDKLocalizedString("People", comment: "Describes a people segmentation operation that is applied to a photo."),
                    description: SDKLocalizedString(
                        "Suitable for portraits. It features detailed edges on a person, but cannot detect objects or animals.",
                        comment: "Descriptive text about a background removal functionality."
                    ),
                    icon: UIImage(systemName: "person.3.fill")
                )
                /* case .personInstance:
                 SegmentationOption(
                     type: .personInstance,
                     title: SDKLocalizedString(
                         "People (Selective)",
                         comment: "Describes a selective people segmentation operation that is applied to a photo."
                     ),
                     description: SDKLocalizedString(
                         "Includes the individuals based on the quality of their images.",
                         comment: "Descriptive text about a background removal functionality."
                     ),
                     icon: UIImage(systemName: "person.and.background.dotted")
                 )*/
            }
        }
    }
}
