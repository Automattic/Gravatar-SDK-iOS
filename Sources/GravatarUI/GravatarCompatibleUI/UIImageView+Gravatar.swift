import Foundation
import Gravatar
import UIKit

// MARK: - Associated Object

private let taskIdentifierKey: UnsafeMutableRawPointer = .allocate(byteCount: 1, alignment: MemoryLayout<UInt8>.alignment)
private let indicatorKey: UnsafeMutableRawPointer = .allocate(byteCount: 1, alignment: MemoryLayout<UInt8>.alignment)
private let indicatorTypeKey: UnsafeMutableRawPointer = .allocate(byteCount: 1, alignment: MemoryLayout<UInt8>.alignment)
private let placeholderKey: UnsafeMutableRawPointer = .allocate(byteCount: 1, alignment: MemoryLayout<UInt8>.alignment)
private let imageTaskKey: UnsafeMutableRawPointer = .allocate(byteCount: 1, alignment: MemoryLayout<UInt8>.alignment)
private let dataTaskKey: UnsafeMutableRawPointer = .allocate(byteCount: 1, alignment: MemoryLayout<UInt8>.alignment)
private let imageDownloaderKey: UnsafeMutableRawPointer = .allocate(byteCount: 1, alignment: MemoryLayout<UInt8>.alignment)
private let sourceURLKey: UnsafeMutableRawPointer = .allocate(byteCount: 1, alignment: MemoryLayout<UInt8>.alignment)

@MainActor
extension GravatarWrapper where Component: UIImageView {
    /// Describes which indicator type is going to be used. Default is `.none`, which means no activity indicator will be shown.
    public var activityIndicatorType: ActivityIndicatorType {
        get {
            getAssociatedObject(component, indicatorTypeKey) ?? .none
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
            setRetainedAssociatedObject(component, indicatorTypeKey, newValue)
        }
    }

    /// The activityIndicator to show during network operations .
    public private(set) var activityIndicator: ActivityIndicatorProvider? {
        get {
            let box: Box<ActivityIndicatorProvider>? = getAssociatedObject(component, indicatorKey)
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

            setRetainedAssociatedObject(component, indicatorKey, newValue.map(Box.init))
        }
    }

    /// A `Placeholder` will be shown in the imageview until the download completes.
    public private(set) var placeholder: UIImage? {
        get { getAssociatedObject(component, placeholderKey) }
        set {
            if let newPlaceholder = newValue {
                component.image = newPlaceholder
            } else {
                component.image = nil
            }
            setRetainedAssociatedObject(component, placeholderKey, newValue)
        }
    }

    public private(set) var sourceURL: URL? {
        get {
            getAssociatedObject(component, sourceURLKey)
        }
        set {
            setRetainedAssociatedObject(component, sourceURLKey, newValue)
        }
    }

    public private(set) var taskIdentifier: UInt? {
        get {
            let box: Box<UInt>? = getAssociatedObject(component, taskIdentifierKey)
            return box?.value
        }
        set {
            let box = newValue.map { Box($0) }
            setRetainedAssociatedObject(component, taskIdentifierKey, box)
        }
    }

    public private(set) var imageDownloader: ImageDownloader? {
        get {
            let box: Box<ImageDownloader>? = getAssociatedObject(component, imageDownloaderKey)
            return box?.value
        }
        set {
            let box = newValue.map { Box($0) }
            setRetainedAssociatedObject(component, imageDownloaderKey, box)
        }
    }

    public func cancelImageDownload() async {
        if let sourceURL {
            await imageDownloader?.cancelTask(for: sourceURL)
        }
    }

    /// Downloads the Gravatar profile image and sets it to this UIImageView. Throws ``ImageFetchingComponentError``.
    ///
    /// - Parameters:
    ///   - avatarID: an `AvatarIdentifier`
    ///   - placeholder: A placeholder to show while downloading the image.
    ///   - rating: Image rating accepted to be downloaded.
    ///   - preferredSize: Preferred "point" size of the image that will be downloaded. If not provided, `layoutIfNeeded()` is called on this view to get its
    /// real bounds and those bounds are used.
    ///   You can get a performance benefit by setting this value since it will avoid the `layoutIfNeeded()` call.
    ///   - options: A set of options to define image setting behaviour. See ``ImageSettingOption`` for more info.
    /// - Returns: The ``ImageDownloadResult`` or throws ``ImageFetchingComponentError``.
    @discardableResult
    public func setImage(
        avatarID: AvatarIdentifier,
        placeholder: UIImage? = nil,
        rating: Rating? = nil,
        preferredSize: CGSize? = nil,
        defaultAvatarOption: DefaultAvatarOption? = nil,
        options: [ImageSettingOption]? = nil
    ) async throws -> ImageDownloadResult {
        let pointsSize = pointImageSize(from: preferredSize)
        let downloadOptions = ImageSettingOptions(options: options).deriveDownloadOptions(
            garavatarRating: rating,
            preferredSize: pointsSize,
            defaultAvatarOption: defaultAvatarOption
        )

        let gravatarURL = AvatarURL(with: avatarID, options: downloadOptions.avatarQueryOptions)?.url
        return try await setImage(with: gravatarURL, placeholder: placeholder, options: options)
    }

    /// Downloads the image and sets it to this UIImageView. Throws ``ImageFetchingComponentError``.
    /// - Parameters:
    ///   - source: URL for the image.
    ///   - placeholder: A placeholder to show while downloading the image.
    ///   - options: A set of options to define image setting behaviour. See ``ImageSettingOption`` for more info.
    /// - Returns: The ``ImageDownloadResult`` or throws ``ImageFetchingComponentError``.
    public func setImage(
        with source: URL?,
        placeholder: UIImage? = nil,
        options: [ImageSettingOption]? = nil
    ) async throws -> ImageDownloadResult {
        var mutatingSelf = self
        guard let source else {
            mutatingSelf.placeholder = placeholder
            mutatingSelf.taskIdentifier = nil
            mutatingSelf.sourceURL = nil
            throw ImageFetchingComponentError.requestError(reason: .emptyURL)
        }
        mutatingSelf.sourceURL = source
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

        let networkManager = options.imageDownloader ?? ImageDownloadService(cache: options.imageCache)
        mutatingSelf.imageDownloader = networkManager // Retain the network manager otherwise the completion tasks won't be done properly

        let result: ImageDownloadResult
        do {
            result = try await networkManager.fetchImage(with: source, forceRefresh: options.forceRefresh, processingMethod: options.processingMethod)
        } catch {
            maybeIndicator?.stopAnimatingView()
            guard issuedIdentifier == self.taskIdentifier else {
                throw ImageFetchingComponentError.outdatedTask(result: Result.failure(error.map()), source: source)
            }
            mutatingSelf.taskIdentifier = nil
            mutatingSelf.sourceURL = nil
            throw error.map().map()
        }
        maybeIndicator?.stopAnimatingView()
        guard issuedIdentifier == self.taskIdentifier else {
            throw ImageFetchingComponentError.outdatedTask(result: Result.success(result), source: source)
        }
        mutatingSelf.taskIdentifier = nil
        mutatingSelf.sourceURL = nil
        mutatingSelf.placeholder = nil

        switch options.transition {
        case .none:
            component.image = result.image
        case .fade(let duration):
            await self.transition(for: component, into: result.image, duration: duration)
        }
        return result
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

    private func transition(for component: Component?, into image: UIImage, duration: Double) async {
        guard let component else { return }
        await withUnsafeContinuation { continuation in
            UIView.transition(
                with: component,
                duration: duration,
                options: [.transitionCrossDissolve],
                animations: { component.image = image },
                completion: { _ in
                    continuation.resume()
                }
            )
        }
    }
}

extension CGSize {
    fileprivate var biggestSide: CGFloat {
        max(width, height)
    }
}
