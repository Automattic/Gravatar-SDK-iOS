import UIKit

struct SegmentationOption {
    let type: SegmentationType
    let title: String
    let description: String
    let icon: UIImage?

    static func makeSegmentationOptions() -> [SegmentationOption] {
        SegmentationType.supportedTypes.map { type in
            switch type {
            case .foreground:
                SegmentationOption(
                    type: .foreground,
                    title: SDKLocalizedString(
                        "Foreground",
                        comment: "Describes foreground of a photo that can be isolated from the background."
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
                        "Includes all the people.",
                        comment: "Descriptive text about a background removal functionality."
                    ),
                    icon: UIImage(systemName: "person.3.fill")
                )
            case .personInstance:
                SegmentationOption(
                    type: .personInstance,
                    title: SDKLocalizedString(
                        "People (Selective)",
                        comment: "Describes a selective people segmentation operation that is applied to a photo."
                    ),
                    description: SDKLocalizedString(
                        "Includes the people who have clear faces.",
                        comment: "Descriptive text about a background removal functionality."
                    ),
                    icon: UIImage(systemName: "person.and.background.dotted")
                )
            }
        }
    }
}
