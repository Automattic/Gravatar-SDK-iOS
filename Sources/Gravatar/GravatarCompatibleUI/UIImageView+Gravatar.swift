import Foundation
import UIKit

public typealias GravatarImageSetCompletion = ((Result<GravatarImageDownloadResult, GravatarImageSetError>) -> Void)

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
    public var activityIndicatorType: GravatarActivityIndicatorType {
        get {
            return getAssociatedObject(component, &indicatorTypeKey) ?? .none
        }
        
        set {
            switch newValue {
            case .none:
                activityIndicator = nil
            case .activity:
                activityIndicator = DefaultActivityIndicator()
            case .custom(let indicator):
                activityIndicator = indicator
            }
            setRetainedAssociatedObject(component, &indicatorTypeKey, newValue)
        }
    }
    
    /// The activityIndicator to show during network operations .
    public private(set) var activityIndicator: GravatarActivityIndicator? {
        get {
            let box: Box<GravatarActivityIndicator>? = getAssociatedObject(component, &indicatorKey)
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
                    equalTo: component.centerXAnchor).isActive = true
                newIndicatorView.centerYAnchor.constraint(
                    equalTo: component.centerYAnchor).isActive = true
                
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
        get { return getAssociatedObject(component, &placeholderKey) }
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
            return getAssociatedObject(component, &dataTaskKey)
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
    
    public private(set) var imageDownloader: GravatarImageRetrieverProtocol? {
        get {
            let box: Box<GravatarImageRetrieverProtocol>? = getAssociatedObject(component, &imageDownloaderKey)
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
    /// - Parameters:
    ///   - email: Gravatar account email.
    ///   - placeholder: A placeholder to show while downloading the image.
    ///   - rating: Gravatar image rating.
    ///   - preferredSize: Preferred "point" size of the image that will be downloaded. If not provided, layoutIfNeeded() is called on this view to get its real bounds and those bounds are used.
    ///   You can get a performance benefit by setting this value since it will avoid the `layoutIfNeeded()` call.
    ///   - options: A set of options to define image setting behaviour. See `GravatarImageSettingOption` for more info.
    ///   - completionHandler: Completion block that's called when image downloading and setting completes.
    @discardableResult
    public func setImage(email: String,
                         placeholder: UIImage? = nil,
                         rating: GravatarRating = GravatarRating.default,
                         preferredSize: CGSize? = nil,
                         options: [GravatarImageSettingOption]? = nil,
                         completionHandler: GravatarImageSetCompletion? = nil) -> CancellableDataTask?
    {
        let gravatarURL = GravatarURL.gravatarUrl(for: email, size: calculatedLongerEdgeSize(preferredSize: preferredSize), rating: rating)
        return setImage(with: gravatarURL, placeholder: placeholder, options: options, completionHandler: completionHandler)
    }
    
    /// Downloads the  image and sets it to this UIImageView.
    /// - Parameters:
    ///   - source: URL for the image.
    ///   - placeholder: A placeholder to show while downloading the image.
    ///   - options: A set of options to define image setting behaviour. See `GravatarImageSettingOption` for more info.
    ///   - completionHandler: Completion block that's called when image downloading and setting completes.
    @discardableResult
    public func setImage(with source: URL?,
                         placeholder: UIImage? = nil,
                         options: [GravatarImageSettingOption]? = nil,
                         completionHandler: GravatarImageSetCompletion? = nil) -> CancellableDataTask?
    {
        var mutatingSelf = self
        guard let source = source else {
            mutatingSelf.placeholder = placeholder
            mutatingSelf.taskIdentifier = nil
            completionHandler?(.failure(GravatarImageSetError.requestError(reason: .emptyURL)))
            return nil
        }
        
        let options = GravatarImageSettingOptions(options: options)
                
        let isEmptyImage = component.image == nil && self.placeholder == nil
        if options.removeCurrentImageWhileLoading || isEmptyImage {
            // Always set placeholder while there is no image/placeholder yet.
            mutatingSelf.placeholder = placeholder
        }
        let maybeIndicator = activityIndicator
        maybeIndicator?.startAnimatingView()
        
        let issuedIdentifier = SimpleCounter.next()
        mutatingSelf.taskIdentifier = issuedIdentifier
        
        let networkManager = options.imageDownloader ?? GravatarImageRetriever(imageCache: options.imageCache)
        mutatingSelf.imageDownloader = networkManager // Retain the network manager otherwise the completion tasks won't be done properly
        let task = networkManager.retrieveImage(with: source, forceRefresh: options.forceRefresh, processor: options.processor) { [weak component] result in
            DispatchQueue.main.async {
                self.activityIndicator?.stopAnimatingView()
                guard issuedIdentifier == self.taskIdentifier else {
                    let reason: GravatarImageDownload.ImageSettingErrorReason
                    do {
                        let value = try result.get()
                        reason = .notCurrentSourceTask(result: value, error: nil, source: source)
                    } catch {
                        reason = .notCurrentSourceTask(result: nil, error: error, source: source)
                    }
                    let error = GravatarImageSetError.imageSettingError(reason: reason)
                    completionHandler?(.failure(error))
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
                        completionHandler?(result.convert())
                        return
                    case .fade(let duration):
                        self.transition(for: component, into: value.image, duration: duration) {
                            completionHandler?(result.convert())
                        }
                    }
                case .failure:
                    completionHandler?(result.convert())
                }
            }
        }
        mutatingSelf.downloadTask = task
        return task
    }
    
    private func calculatedLongerEdgeSize(preferredSize: CGSize?) -> Int {
        let size = calculatedSize(preferredSize: preferredSize)
        let targetSize = max(size.width, size.height) * UIScreen.main.scale
        return Int(targetSize)
    }
    
    private func calculatedSize(preferredSize: CGSize?) -> CGSize {
        var size = GravatarImageDownloadOptions.defaultSize
        if let preferredSize {
            size = preferredSize
        }
        else {
            component.layoutIfNeeded()
            if component.bounds.size.equalTo(.zero) == false {
                size = component.bounds.size
            }
        }
        return size
    }
    
    private func transition(for component: Component?, into image: UIImage, duration: Double, completion: @escaping ()->Void) {
        guard let component else { return }
        UIView.transition(
            with: component,
            duration: duration,
            options: [.transitionCrossDissolve],
            animations: { component.image = image },
            completion: { finished in
                completion()
            }
        )
    }
}
