//
//  File.swift
//
//
//  Created by Pinar Olguc on 18.01.2024.
//

import Foundation
import UIKit

public extension NSNotification.Name {
    static let GravatarUpdateNotification = NSNotification.Name(rawValue: "GravatarUpdateNotification")
}

// MARK: - Associated Object
private var taskIdentifierKey: Void?
private var indicatorKey: Void?
private var indicatorTypeKey: Void?
private var placeholderKey: Void?
private var imageTaskKey: Void?
private var notificationWrapperKey: Void?
private var dataTaskKey: Void?

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
    
    private var downloadTask: CancellableDataTask? {
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
    
    private func setDownloadTask(_ newValue: CancellableDataTask?) {
        setRetainedAssociatedObject(component, &dataTaskKey, newValue)
    }
    
    private var notificationWrapper: NotificationWrapper? {
        get {
            return getAssociatedObject(component, &notificationWrapperKey)
        }
        set {
            setRetainedAssociatedObject(component, &notificationWrapperKey, newValue)
        }
    }
    
    public func listenForGravatarChanges(forEmail trackedEmail: String) {
        if let currentObersver = notificationWrapper?.observer {
            NotificationCenter.default.removeObserver(currentObersver)
            setRetainedAssociatedObject(component, &notificationWrapperKey, nil as NotificationWrapper?)
        }
        
        let observer = NotificationCenter.default.addObserver(forName: .GravatarUpdateNotification, object: nil, queue: nil) { [weak component] (notification) in
            guard let userInfo = notification.userInfo,
                  let email = userInfo[GravatarNotificationKey.email] as? String,
                  email == trackedEmail,
                  let image = userInfo[GravatarNotificationKey.image] as? UIImage else {
                return
            }
            
            component?.image = image
        }
        setRetainedAssociatedObject(component, &notificationWrapperKey, NotificationWrapper(observer: observer))
    }
    
    public func cancelImageDownload() {
        downloadTask?.cancel()
        setDownloadTask(nil)
    }
    
    public func setImage(
        email: String,
        placeholder: UIImage? = nil,
        options: [GravatarDownloadOption]? = nil,
        completionHandler: ((Result<GravatarImageDownloadResult, GravatarError>) -> Void)? = nil)
    {
        let options = GravatarDownloadOptions(options: options)
        let gravatarURL = Gravatar.gravatarUrl(for: email, size: calculatedLongerEdgeSize(preferredSize: options.preferredSize), rating: options.gravatarRating)
        
        setImage(with: gravatarURL, placeholder: placeholder, parsedOptions: options, completionHandler: completionHandler)
    }
    
    public func setImage(
        with source: URL?,
        placeholder: UIImage? = nil,
        parsedOptions: GravatarDownloadOptions,
        completionHandler: ((Result<GravatarImageDownloadResult, GravatarError>) -> Void)? = nil) {
            
            var mutatingSelf = self
            guard let source = source else {
                mutatingSelf.placeholder = placeholder
                mutatingSelf.taskIdentifier = nil
                completionHandler?(.failure(GravatarError.requestError(reason: .emptyURL)))
                return
            }
            
            var options = parsedOptions
            
            if options.shouldCancelOngoingDownload {
                cancelImageDownload()
            }
            
            let isEmptyImage = component.image == nil && self.placeholder == nil
            if options.removeCurrentImageWhileLoading || isEmptyImage {
                // Always set placeholder while there is no image/placeholder yet.
                mutatingSelf.placeholder = placeholder
            }
            let maybeIndicator = activityIndicator
            maybeIndicator?.startAnimatingView()
            
            let issuedIdentifier = TaskCounter.next()
            mutatingSelf.taskIdentifier = issuedIdentifier
            
            // Update preferredSize if needed
            options.preferredSize = calculatedSize(preferredSize: options.preferredSize)
            
            let networkManager = GravatarNetworkManager()
            let task = networkManager.retrieveImage(with: source, options: options) { result in
                DispatchQueue.main.async {
                    self.activityIndicator?.stopAnimatingView()
                    guard issuedIdentifier == self.taskIdentifier else {
                        let reason: GravatarImageSettingError
                        do {
                            let value = try result.get()
                            reason = .notCurrentSourceTask(result: value, error: nil, source: source)
                        } catch {
                            reason = .notCurrentSourceTask(result: nil, error: error, source: source)
                        }
                        let error = GravatarError.imageSettingError(reason: reason)
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
                            self.component.image = value.image
                            completionHandler?(result)
                            return
                        case .fade(let duration):
                            UIView.transition(
                                with: self.component,
                                duration: duration,
                                options: [.transitionCrossDissolve, .allowUserInteraction],
                                animations: { mutatingSelf.component.image = value.image },
                                completion: { finished in
                                    completionHandler?(result)
                                }
                            )
                        }
                    case .failure:
                        completionHandler?(result)
                    }
                }
            }
            mutatingSelf.downloadTask = task
        }
    
    private func calculatedLongerEdgeSize(preferredSize: CGSize?) -> Int {
        let size = calculatedSize(preferredSize: preferredSize)
        let targetSize = max(size.width, size.height) * UIScreen.main.scale
        return Int(targetSize)
    }
    
    private func calculatedSize(preferredSize: CGSize?) -> CGSize {
        var size = GravatarDownloadOptions.defaultSize
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
}
