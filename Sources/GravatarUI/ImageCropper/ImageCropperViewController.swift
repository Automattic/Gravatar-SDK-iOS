import CoreGraphics
import UIKit

class ImageCropperViewController: UIViewController, UIScrollViewDelegate {
    private enum Constants {
        static let overlayColor = UIColor.black.withAlphaComponent(0.2)
        static let backgroundColor = UIColor.black
        static let scrollViewHorizontalPadding: CGFloat = .DS.Padding.medium
        static let cropSize: CGFloat = 320
        static let maxOutputImageSizeInPixels: CGFloat = 1024
    }

    // ScrollView for zooming and panning
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isScrollEnabled = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bouncesZoom = true
        scrollView.bounces = true
        scrollView.contentMode = .scaleAspectFit
        return scrollView
    }()

    // ImageView for displaying the image
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    // View to show the cropping frame
    private let cropFrameView: CropFrameOverlayView = {
        let cropFrameView = CropFrameOverlayView()
        cropFrameView.translatesAutoresizingMaskIntoConstraints = false
        cropFrameView.backgroundColor = .clear
        cropFrameView.isUserInteractionEnabled = false
        return cropFrameView
    }()

    let inputImage: UIImage
    var onCompletion: ((UIImage, Bool) -> Void)?
    var onCancel: (() -> Void)?

    init(image: UIImage) {
        self.inputImage = image
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let appearance = UINavigationBarAppearance()
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance

        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        view.addSubview(cropFrameView)
        configureConstraints()

        title = Localized.title
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: Localized.useButtonTitle,
            style: .plain,
            target: self,
            action: #selector(cropWasPressed)
        )
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: Localized.cancelButtonTitle,
            style: .plain,
            target: self,
            action: #selector(cancelWasPressed)
        )

        view.backgroundColor = Constants.backgroundColor
        scrollView.delegate = self

        setImageToCrop(image: inputImage)
    }

    private func configureConstraints() {
        let scrollViewWidthConstraint = scrollView.widthAnchor.constraint(equalToConstant: Constants.cropSize)
        scrollViewWidthConstraint.priority = .defaultLow

        NSLayoutConstraint.activate([
            // scrollView
            scrollView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor),
            view.trailingAnchor.constraint(greaterThanOrEqualTo: scrollView.trailingAnchor),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(greaterThanOrEqualTo: scrollView.bottomAnchor),
            scrollView.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor, constant: .DS.Padding.half),
            scrollView.heightAnchor.constraint(equalTo: scrollView.widthAnchor),
            scrollView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scrollViewWidthConstraint,
            // imageView
            imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            // crop frame
            cropFrameView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cropFrameView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cropFrameView.topAnchor.constraint(equalTo: view.topAnchor),
            cropFrameView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        imageView.frame = CGRect(x: 0, y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
    }

    func setImageToCrop(image: UIImage) {
        imageView.image = image
        scrollView.layoutIfNeeded()
        scrollView.clipsToBounds = false
        imageView.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        scrollView.contentSize = image.size
        let scaleHeight = scrollView.frame.size.height / scrollView.contentSize.height
        let scaleWidth = scrollView.frame.size.width / scrollView.contentSize.width
        let minScale = max(scaleWidth, scaleHeight) // chosing the "max" to avoid having empty black space inside the crop frame
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = 1
        scrollView.zoomScale = minScale

        centerScrollViewContent()
    }

    private func centerScrollViewContent() {
        let scrollViewSize = scrollView.bounds.size
        let contentSize = scrollView.contentSize

        // Calculate the horizontal and vertical offsets to center the content
        let horizontalOffset = max(0, (contentSize.width - scrollViewSize.width) / 2)
        let verticalOffset = max(0, (contentSize.height - scrollViewSize.height) / 2)

        // Set the contentOffset to scroll to the calculated position
        scrollView.setContentOffset(CGPoint(x: horizontalOffset, y: verticalOffset), animated: false)
    }

    // MARK: - Action Handlers

    @objc
    func cropWasPressed() {
        guard let image = imageView.image?.correctlyOriented else { return }

        let cropFrame = scrollView.frame
        let zoomScale = scrollView.zoomScale

        // Calculate the visible content offset in the scroll view (relative to the zoomed content)
        let contentOffset = scrollView.contentOffset

        // Convert crop frame into the image's coordinate system, adjusted by zoom scale
        let visibleRect = CGRect(
            x: (contentOffset.x + cropFrame.origin.x - scrollView.frame.origin.x) / zoomScale,
            y: (contentOffset.y + cropFrame.origin.y - scrollView.frame.origin.y) / zoomScale,
            width: cropFrame.width / zoomScale,
            height: cropFrame.height / zoomScale
        )

        // cropping(to:) can return inequal edges since it adjusts the cropping rect to integral bounds.
        guard let croppedCGImage = image.cgImage?.cropping(to: visibleRect) else { return }

        let croppedUIImage = UIImage(cgImage: croppedCGImage, scale: UIScreen.main.scale, orientation: .up)

        guard let result = croppedUIImage.square(maxLength: Constants.maxOutputImageSizeInPixels) else { return }
        onCompletion?(result, true)
    }

    @objc
    func cancelWasPressed() {
        onCancel?()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Update the scrollViewFrame in the overlay view when the layout changes
        let scrollViewFrameInSuperview = scrollView.convert(scrollView.bounds, to: view)
        cropFrameView.scrollViewFrame = scrollViewFrameInSuperview
    }

    // MARK: - UIScrollViewDelegate Methods

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }

    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        // NO-OP:
        // Required to enable scrollView Zooming
    }

    static func wrappedInNavigationViewController(
        image: UIImage,
        onCompletion: @escaping ((UIImage, Bool) -> Void),
        onCancel: @escaping (() -> Void)
    ) -> UINavigationController {
        let imageCropController = ImageCropperViewController(image: image)
        imageCropController.onCancel = onCancel
        imageCropController.onCompletion = onCompletion
        let navigationController = UINavigationController(rootViewController: imageCropController)
        navigationController.modalPresentationStyle = .formSheet
        return navigationController
    }

    private enum Localized {
        static let title = SDKLocalizedString(
            "ImageCropper.title",
            value: "Resize & Crop",
            comment: "Screen title. Resize and crop an image."
        )
        static let useButtonTitle = SDKLocalizedString(
            "ImageCropper.useButtonTitle",
            value: "Use",
            comment: "Use the current image"
        )
        static let cancelButtonTitle = SDKLocalizedString(
            "ImageCropper.cropButtonTitle",
            value: "Cancel",
            comment: "Cancel the crop"
        )
    }
}

@MainActor
extension UIImage {
    fileprivate func square(maxLength maxLengthInPixels: CGFloat) -> UIImage? {
        let scale = UIScreen.main.scale
        let smallerEgde = min(size.width * scale, size.height * scale)
        let squareEdge = min(maxLengthInPixels, smallerEgde)
        return downsize(to: .init(width: squareEdge, height: squareEdge))
    }

    // Resize the UIImage fitting within a specified maximum size.
    private func downsize(to targetSizeInPixels: CGSize) -> UIImage? {
        let scale = UIScreen.main.scale
        let currentSizeInPixels: CGSize = .init(width: size.width * scale, height: size.height * scale)
        // Downsize if this is not a square (to fix the inequal edges produced by cropping(to:) )
        // OR if size is bigger than target.
        guard currentSizeInPixels.width != currentSizeInPixels.height ||
            targetSizeInPixels.width < currentSizeInPixels.width ||
            targetSizeInPixels.height < currentSizeInPixels.height
        else { return self }
        let newLenght = floor(min(targetSizeInPixels.width, targetSizeInPixels.height))
        let newSize = CGSize(width: newLenght, height: newLenght)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        let resizedImage = renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
        return resizedImage
    }

    /// A UIImage instance with corrected orientation.If the instance's orientation is already `.up`, it simply returns the original.
    fileprivate var correctlyOriented: UIImage? {
        if imageOrientation == .up { return self }

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return normalizedImage
    }
}
