import UIKit

class ImageCropperViewController: UIViewController, UIScrollViewDelegate {
    private enum Constants {
        static let overlayColor = UIColor.black.withAlphaComponent(0.2)
        static let backgroundColor = UIColor.black
        static let scrollViewHorizontalPadding: CGFloat = .DS.Padding.medium
        static let cropSize: CGFloat = 320
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
        let screenScale = UIScreen.main.scale
        let zoomScale = scrollView.zoomScale
        let oldSize = inputImage.size
        let resizeRect = CGRect(x: 0, y: 0, width: oldSize.width * zoomScale, height: oldSize.height * zoomScale)
        let clippingRect = CGRect(
            x: scrollView.contentOffset.x * screenScale,
            y: scrollView.contentOffset.y * screenScale,
            width: scrollView.frame.width * screenScale,
            height: scrollView.frame.height * screenScale
        )

        if scrollView.contentOffset.x == 0 &&
            scrollView.contentOffset.y == 0 &&
            oldSize.width == clippingRect.width &&
            oldSize.height == clippingRect.height
        {
            onCompletion?(inputImage, false)
            return
        }

        // Resize
        UIGraphicsBeginImageContextWithOptions(resizeRect.size, false, screenScale)
        inputImage.draw(in: resizeRect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        // Crop
        guard let clippedImageRef = scaledImage?.cgImage?.cropping(to: clippingRect.integral) else {
            return
        }

        let clippedImage = UIImage(cgImage: clippedImageRef, scale: screenScale, orientation: .up)
        onCompletion?(clippedImage, true)
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
