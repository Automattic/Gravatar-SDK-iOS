@testable import GravatarUI
import SnapshotTesting
import XCTest

final class CropFrameOverlayViewTests: XCTestCase {
    enum Constants {
        static let imageSize: CGSize = .init(width: 320, height: 480)
    }

    override func invokeTest() {
        withSnapshotTesting(record: .failed) {
            super.invokeTest()
        }
    }

    @MainActor
    func testCropFrameOverlay() throws {
        let image = UIImage.create(size: Constants.imageSize)
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: Constants.imageSize.width).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: Constants.imageSize.height).isActive = true
        imageView.contentMode = .scaleAspectFill
        let containerView = CropFrameOverlayView()
        // center the cropping layer
        containerView.scrollViewFrame = .init(
            origin: .init(x: 0, y: (Constants.imageSize.height - Constants.imageSize.width) / 2),
            size: .init(width: Constants.imageSize.width, height: Constants.imageSize.width)
        )
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.widthAnchor.constraint(equalToConstant: Constants.imageSize.width).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: Constants.imageSize.height).isActive = true
        imageView.addSubview(containerView)
        containerView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        containerView.backgroundColor = .clear
        assertSnapshot(of: imageView, as: .image)
    }
}
