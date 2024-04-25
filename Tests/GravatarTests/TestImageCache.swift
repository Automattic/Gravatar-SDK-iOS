import Gravatar
import UIKit

actor TestImageCache: ImageCaching {
    var dict: [URL: UIImage] = [:]

    var getImageCallCount = 0
    var setTaskCallCount = 0
    var setImageCallsCount = 0

    func setImage(_ image: UIImage, for key: URL) async {
        setImageCallsCount += 1
        dict[key] = image
    }

    func setTask(_ task: Task<UIImage, Error>, for key: URL) async {
        setTaskCallCount += 1
    }

    func getImage(for key: URL) async throws -> UIImage? {
        getImageCallCount += 1
        return dict[key]
    }
}
