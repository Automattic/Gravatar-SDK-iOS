import Foundation
import UIKit

public typealias ImageSetCompletion = (Result<ImageDownloadResult, ImageFetchingComponentError>) -> Void

// MARK: - Associated Object

private var taskIdentifierKey: Void?
private var indicatorKey: Void?
private var indicatorTypeKey: Void?
private var placeholderKey: Void?
private var imageTaskKey: Void?
private var dataTaskKey: Void?
private var imageDownloaderKey: Void?

extension GravatarWrapper where Component: UIImageView {
    /// Describes which indicator type is going to be used. Default is `.none`, which means no activity indicator will be shown.
    public var activityIndicatorType: ActivityIndicatorType {
        get {
            getAssociatedObject(component, &indicatorTypeKey) ?? .none
        }

        set {
            switch newValue {
            case .none:
                activityIndicator = nil
            case .activity:
                activityIndicator = DefaultActivityIndicatorProvider()
            case .custom(let indicator):
                activityIndicator = indicator
            }
            setRetainedAssociatedObject(component, &indicatorTypeKey, newValue)
        }
    }

    /// The activityIndicator to show during network operations .
    public private(set) var activityIndicator: ActivityIndicatorProvider? {
        get {
            let box: Box<ActivityIndicatorProvider>? = getAssociatedObject(component, &indicatorKey)
            return box?.value
        }

        set {
            // Remove previous
            if let previousIndicator = activityIndicator {
                previousIndicator.view.removeFromSuperview()
            }

            // Add new
            if let newIndicator = newValue {
                let newIndicatorView = newIndicator.view
                component.addSubview(newIndicatorView)
                newIndicatorView.translatesAutoresizingMaskIntoConstraints = false
                newIndicatorView.centerXAnchor.constraint(
                    equalTo: component.centerXAnchor
                ).isActive = true
                newIndicatorView.centerYAnchor.constraint(
                    equalTo: component.centerYAnchor
                ).isActive = true

                switch newIndicator.sizeStrategy(in: component) {
                case .intrinsicSize:
                    break
                case .full:
                    newIndicatorView.heightAnchor.constraint(equalTo: component.heightAnchor, constant: 0).isActive = true
                    newIndicatorView.widthAnchor.constraint(equalTo: component.widthAnchor, constant: 0).isActive = true
                case .size(let size):
                    newIndicatorView.heightAnchor.constraint(equalToConstant: size.height).isActive = true
                    newIndicatorView.widthAnchor.constraint(equalToConstant: size.width).isActive = true
                }

                newIndicator.view.isHidden = true
            }

            setRetainedAssociatedObject(component, &indicatorKey, newValue.map(Box.init))
        }
    }

    /// A `Placeholder` will be shown in the imageview until the download completes.
    public private(set) var placeholder: UIImage? {
        get { getAssociatedObject(component, &placeholderKey) }
        set {
            if let newPlaceholder = newValue {
                component.image = newPlaceholder
            } else {
                component.image = nil
            }
            setRetainedAssociatedObject(component, &placeholderKey, newValue)
        }
    }

    public private(set) var downloadTask: CancellableDataTask? {
        get {
            getAssociatedObject(component, &dataTaskKey)
        }
        set {
            setDownloadTask(newValue)
        }
    }

    public private(set) var taskIdentifier: UInt? {
        get {
            let box: Box<UInt>? = getAssociatedObject(component, &taskIdentifierKey)
            return box?.value
        }
        set {
            let box = newValue.map { Box($0) }
            setRetainedAssociatedObject(component, &taskIdentifierKey, box)
        }
    }

    public private(set) var imageDownloader: ImageDownloader? {
        get {
            let box: Box<ImageDownloader>? = getAssociatedObject(component, &imageDownloaderKey)
            return box?.value
        }
        set {
            let box = newValue.map { Box($0) }
            setRetainedAssociatedObject(component, &imageDownloaderKey, box)
        }
    }

    private func setDownloadTask(_ newValue: CancellableDataTask?) {
        setRetainedAssociatedObject(component, &dataTaskKey, newValue)
    }

    public func cancelImageDownload() {
        downloadTask?.cancel()
        setDownloadTask(nil)
    }

    /// Downloads the Gravatar profile image and sets it to this UIImageView.
    ///
    /// - Parameters:
    ///   - email: Gravatar account email.
    ///   - placeholder: A placeholder to show while downloading the image.
    ///   - rating: Image rating accepted to be downloaded.
    ///   - preferredSize: Preferred "point" size of the image that will be downloaded. If not provided, `layoutIfNeeded()` is called on this view to get its
    /// real bounds and those bounds are used.
    ///   You can get a performance benefit by setting this value since it will avoid the `layoutIfNeeded()` call.
    ///   - options: A set of options to define image setting behaviour. See ``ImageSettingOption`` for more info.
    ///   - completionHandler: Completion block that's called when image downloading and setting completes.
    /// - Returns: The task performing the download operation which can be cancelled.
    @discardableResult
    public func setImage(
        email: String,
        placeholder: UIImage? = nil,
        rating: Rating? = nil,
        preferredSize: CGSize? = nil,
        defaultImageOption: DefaultImageOption? = nil,
        options: [ImageSettingOption]? = nil,
        completionHandler: ImageSetCompletion? = nil
    ) -> CancellableDataTask? {
        let pointsSize = pointImageSize(from: preferredSize)
        let downloadOptions = ImageSettingOptions(options: options).deriveDownloadOptions(
            garavatarRating: rating,
            preferredSize: pointsSize,
            defaultImageOption: defaultImageOption
        )

        let gravatarURL = GravatarURL.gravatarUrl(with: email, options: downloadOptions.imageQueryOptions)
        return setImage(with: gravatarURL, placeholder: placeholder, options: options, completionHandler: completionHandler)
    }

    /// Downloads the  image and sets it to this UIImageView.
    /// - Parameters:
    ///   - source: URL for the image.
    ///   - placeholder: A placeholder to show while downloading the image.
    ///   - options: A set of options to define image setting behaviour. See ``ImageSettingOption`` for more info.
    ///   - completionHandler: Completion block that's called when image downloading and setting completes.
    /// - Returns: The task performing the download operation which can be cancelled.
    @discardableResult
    public func setImage(
        with source: URL?,
        placeholder: UIImage? = nil,
        options: [ImageSettingOption]? = nil,
        completionHandler: ImageSetCompletion? = nil
    ) -> CancellableDataTask? {
        var mutatingSelf = self
        guard let source else {
            mutatingSelf.placeholder = placeholder
            mutatingSelf.taskIdentifier = nil
            completionHandler?(.failure(ImageFetchingComponentError.requestError(reason: .emptyURL)))
            return nil
        }

        let options = ImageSettingOptions(options: options)

        let isEmptyImage = component.image == nil && self.placeholder == nil
        if options.removeCurrentImageWhileLoading || isEmptyImage {
            // Always set placeholder while there is no image/placeholder yet.
            mutatingSelf.placeholder = placeholder
        }
        let maybeIndicator = activityIndicator
        maybeIndicator?.startAnimatingView()

        let issuedIdentifier = SimpleCounter.next()
        mutatingSelf.taskIdentifier = issuedIdentifier

        let networkManager = options.imageDownloader ?? ImageService(cache: options.imageCache)
        mutatingSelf.imageDownloader = networkManager // Retain the network manager otherwise the completion tasks won't be done properly

        let task = networkManager
            .fetchImage(with: source, forceRefresh: options.forceRefresh, processingMethod: options.processingMethod) { [weak component] result in
                DispatchQueue.main.async {
                    maybeIndicator?.stopAnimatingView()
                    guard issuedIdentifier == self.taskIdentifier else {
                        completionHandler?(.failure(.outdatedTask(result: result, source: source)))
                        return
                    }

                    mutatingSelf.downloadTask = nil
                    mutatingSelf.taskIdentifier = nil

                    switch result {
                    case .success(let value):
                        mutatingSelf.placeholder = nil
                        switch options.transition {
                        case .none:
                            component?.image = value.image
                            completionHandler?(result.map())
                            return
                        case .fade(let duration):
                            self.transition(for: component, into: value.image, duration: duration) {
                                completionHandler?(result.map())
                            }
                        }
                    case .failure:
                        completionHandler?(result.map())
                    }
                }
            }
        mutatingSelf.downloadTask = task
        return task
    }

    private func pointImageSize(from size: CGSize?) -> ImageSize? {
        guard let calculatedSize = calculatedSize(preferredSize: size) else {
            return nil
        }
        return .points(calculatedSize)
    }

    // TODO: Create unit test which checks for the correct automated size calculation based on the component size.
    // TODO: At some point this was failing while all tests were passing, and the server was returning the default 80x80px image.
    private func calculatedSize(preferredSize: CGSize?) -> CGFloat? {
        if let preferredSize {
            return preferredSize.biggestSide
        } else {
            component.layoutIfNeeded()
            if component.bounds.size.equalTo(.zero) == false {
                return component.bounds.size.biggestSide
            }
        }
        return nil
    }

    private func transition(for component: Component?, into image: UIImage, duration: Double, completion: @escaping () -> Void) {
        guard let component else { return }
        UIView.transition(
            with: component,
            duration: duration,
            options: [.transitionCrossDissolve],
            animations: { component.image = image },
            completion: { _ in
                completion()
            }
        )
    }
}

extension CGSize {
    fileprivate var biggestSide: CGFloat {
        max(width, height)
    }
}
