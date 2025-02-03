import Foundation
import UIKit

/// Protocol for movable view canvas methods
@MainActor
protocol MovableViewCanvasDelegate: AnyObject {
    /// Called when a movable view is tapped
    ///
    /// - Parameter option: text style options
    /// - Parameter transformations: transformations for the view
    //  func didTapTextView(options: TextOptions, transformations: ViewTransformations)

    /// Called when text is removed
    func didRemoveText()

    /// Called when text is moved
    func didMoveText()

    /// Called when an image is removed
    ///
    ///  - Parameter imageView:the image view that was removed
    func didRemoveImage(_ imageView: StylableImageView)

    /// Called when an image is moved
    ///
    ///  - Parameter imageView:the image view that was moved
    func didMoveImage(_ imageView: StylableImageView)

    /// Called when a touch event on a movable view begins
    func didBeginTouchesOnMovableView()

    /// Called when the touch events on a movable view end
    func didEndTouchesOnMovableView()
}

/// Constants for the canvas
private enum Constants {
    static let animationDuration: TimeInterval = 0.25
    //  static let trashViewSize: CGFloat = KanvasDesign.shared.trashViewSize
    static let trashViewBottomMargin: CGFloat = 93
    static let overlayColor = UIColor.black.withAlphaComponent(0.7)
}

/// View that contains the collection of movable views
@MainActor
final class MovableViewCanvas: IgnoreTouchesView, UIGestureRecognizerDelegate, MovableViewDelegate, NSSecureCoding {
    static var supportsSecureCoding = true

    weak var delegate: MovableViewCanvasDelegate?

    // View that has been tapped
    private var selectedMovableView: MovableView?

    // View being touched at the moment
    private var currentMovableView: MovableView?

    // Touch locations during a long press
    private var touchPosition: [CGPoint] = []

    // Layout
    //   private let overlay: UIView
    //   private let trashView: TrashView

    // Values from which the different gestures start
    private var originTransformations: ViewTransformations

    var isEmpty: Bool {
        movableViews.isEmpty
    }

    /*   var trashCompletion: (() -> Void)? {
         set {
             trashView.completion = newValue
         }
         get {
             return trashView.completion
         }
     }*/

    var movableViews: [MovableView] {
        subviews.compactMap { $0 as? MovableView }
    }

    init() {
        //     overlay = UIView()
        //      trashView = TrashView()
        originTransformations = ViewTransformations()
        super.init(frame: .zero)
        setUpViews()
    }

    private enum CodingKeys: String, CodingKey {
        case originTransformations
        case textViews
        case imageViews
        case movableViews
    }

    required init?(coder: NSCoder) {
        //   overlay = UIView()
        //  trashView = TrashView()

        originTransformations = ViewTransformations()

        super.init(frame: .zero)

        let movableViews = coder.decodeObject(of: [NSArray.self, MovableView.self], forKey: CodingKeys.movableViews.rawValue) as? [MovableView]
        movableViews?.forEach { view in
            addView(
                view: view.innerView,
                transformations: view.transformations,
                location: view.innerView.viewCenter,
                origin: view.originLocation,
                size: view.innerView.viewSize
            )
        }
        setUpViews()
    }

    override func encode(with coder: NSCoder) {
        coder.encode(originTransformations, forKey: CodingKeys.originTransformations.rawValue)

        let movableViews = subviews.compactMap { $0 as? MovableView }
        coder.encode(movableViews, forKey: CodingKeys.movableViews.rawValue)
    }

    // MARK: - Layout

    private func setUpViews() {
        //  setUpOverlay()
        //   setUpTrashView()
    }

    /// Sets up the trash bin used during deletion
    /*  private func setUpTrashView() {
         trashView.accessibilityIdentifier = "Editor Movable View Canvas Trash View"
         trashView.translatesAutoresizingMaskIntoConstraints = false
         addSubview(trashView)

         NSLayoutConstraint.activate([
             trashView.heightAnchor.constraint(equalToConstant: Constants.trashViewSize),
             trashView.widthAnchor.constraint(equalToConstant: Constants.trashViewSize),
             trashView.centerXAnchor.constraint(equalTo: safeLayoutGuide.centerXAnchor),
             trashView.bottomAnchor.constraint(equalTo: safeLayoutGuide.bottomAnchor, constant: -Constants.trashViewBottomMargin),
         ])
     }*/

    /// Sets up the translucent black view used during deletion
    /*   private func setUpOverlay() {
         overlay.accessibilityIdentifier = "Editor Movable View Canvas Overlay"
         overlay.translatesAutoresizingMaskIntoConstraints = false
         overlay.backgroundColor = Constants.overlayColor
         addSubview(overlay)

         NSLayoutConstraint.activate([
             overlay.topAnchor.constraint(equalTo: topAnchor),
             overlay.bottomAnchor.constraint(equalTo: bottomAnchor),
             overlay.leadingAnchor.constraint(equalTo: leadingAnchor),
             overlay.trailingAnchor.constraint(equalTo: trailingAnchor),
         ])

         overlay.alpha = 0
     }*/

    override func layoutSubviews() {
        super.layoutSubviews()
        subviews.compactMap { $0 as? MovableView }.forEach { view in
            view.moveToDefinedPosition()
        }
    }

    // MARK: - Public interface

    /// Adds a new view to the canvas
    /// - Parameters:
    ///   - view: View to be added
    ///   - transformations: Transformations for the view
    ///   - location: Location of the view before transformations
    ///   - origin: Origin point of the view.
    ///   - size: Size of the view
    ///   - animated: Whether to animate the views upon adding. When unarchiving, this is `false`, as an example. (Defaults to `false`)
    func addView(
        view: MovableViewInnerElement,
        transformations: ViewTransformations,
        location: CGPoint,
        origin: CGPoint? = nil,
        size: CGSize,
        animated: Bool = false
    ) {
        let movableView = MovableView(view: view, transformations: transformations)
        movableView.originLocation = origin ?? location
        movableView.delegate = self
        view.viewSize = size
        view.viewCenter = location
        movableView.isUserInteractionEnabled = true
        movableView.isExclusiveTouch = true
        movableView.isMultipleTouchEnabled = true
        movableView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(movableView)

        NSLayoutConstraint.activate([
            movableView.heightAnchor.constraint(equalToConstant: size.height),
            movableView.widthAnchor.constraint(equalToConstant: size.width),
            movableView.centerXAnchor.constraint(equalTo: leadingAnchor, constant: movableView.originLocation.x),
            movableView.centerYAnchor.constraint(equalTo: topAnchor, constant: movableView.originLocation.y),
        ])

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(movableViewTapped(recognizer:)))
        let rotationRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(movableViewRotated(recognizer:)))
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(movableViewPinched(recognizer:)))
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(movableViewPanned(recognizer:)))
        //   let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(movableViewLongPressed(recognizer:)))

        tapRecognizer.delegate = self
        rotationRecognizer.delegate = self
        pinchRecognizer.delegate = self
        panRecognizer.delegate = self
        //    longPressRecognizer.delegate = self

        movableView.addGestureRecognizer(tapRecognizer)
        movableView.addGestureRecognizer(rotationRecognizer)
        movableView.addGestureRecognizer(pinchRecognizer)
        movableView.addGestureRecognizer(panRecognizer)
        //    movableView.addGestureRecognizer(longPressRecognizer)

        let move: () -> Void = {
            movableView.moveToDefinedPosition()
        }
        if animated {
            UIView.animate(withDuration: Constants.animationDuration) {
                move()
            }
        } else {
            move()
        }
    }

    /// Removes the tapped view from the canvas
    func removeSelectedView() {
        selectedMovableView?.removeFromSuperview()
        selectedMovableView = nil
    }

    func removeAllSubviews() {
        subviews.forEach { $0.removeFromSuperview() }
        selectedMovableView = nil
    }

    /// shows the trash icon opened with its red background
    /*  func openTrash() {
           trashView.open()
       }

       /// shows the trash icon closed
     func showTrash() {
           showOverlay(true)
           trashView.superview?.bringSubviewToFront(trashView)
           movableViews.forEach { movableView in
               movableView.fadeOut()
           }
           trashView.close()
       }

       /// hides the trash icon with its red background
       func hideTrash() {
           showOverlay(false)
           movableViews.forEach { movableView in
               movableView.fadeIn()
           }
           trashView.hide()
       }
       */

    // MARK: - Gesture recognizers

    @objc
    func movableViewTapped(recognizer: UITapGestureRecognizer) {
        guard let movableView = recognizer.view as? MovableView else { return }
        movableView.onTap()
    }

    @objc
    func movableViewRotated(recognizer: UIRotationGestureRecognizer) {
        guard let movableView = recognizer.view as? MovableView else { return }

        switch recognizer.state {
        case .began:
            onRecognizerBegan(view: movableView)
            originTransformations.rotation = movableView.rotation
        case .changed:
            let newRotation = originTransformations.rotation + recognizer.rotation
            movableView.rotation = newRotation
            // print("movableViewRotated newRotation : \(newRotation)")
            if let rotationSnapOffset = calculateRotationSnapOffsets(for: movableView) {
                // print("movableViewRotated rotationSnapOffset : \(rotationSnapOffset)")
                movableView.rotation = rotationSnapOffset
            }
        case .ended:
            onRecognizerEnded()
            movableView.onMove()
        case .cancelled, .failed:
            onRecognizerEnded()
        case .possible:
            break
        @unknown default:
            break
        }
    }

    func calculateRotationSnapOffsets(for childView: MovableView, threshold: CGFloat = 0.1, interval: CGFloat = .pi / 4) -> CGFloat? {
        let angle = childView.rotation
        let twoPi = 2 * CGFloat.pi
        let normalizedAngle = angle.truncatingRemainder(dividingBy: twoPi)
        let positiveAngle = normalizedAngle >= 0 ? normalizedAngle : normalizedAngle + twoPi

        // Calculate the closest snap point
        let snappedAngle = round(positiveAngle / interval) * interval

        return abs(snappedAngle - angle) <= threshold ? snappedAngle : nil
    }

    func isRotationVerticalOrHorizontal(for childView: MovableView) -> Bool {
        calculateRotationSnapOffsets(for: childView, threshold: 0, interval: .pi / 2) != nil
    }

    @objc
    func movableViewPinched(recognizer: UIPinchGestureRecognizer) {
        guard let movableView = recognizer.view as? MovableView else { return }

        switch recognizer.state {
        case .began:
            onRecognizerBegan(view: movableView)
            originTransformations.scale = movableView.scale
        case .changed:
            let newScale = originTransformations.scale * recognizer.scale
            movableView.scale = newScale
            // print("movableViewPinched newScale : \(newScale)")
            if let scaleSnapOffset = calculateScaleSnapOffsets(for: movableView) {
                movableView.scale = scaleSnapOffset
            }
        case .ended:
            onRecognizerEnded()
            movableView.onMove()
        case .cancelled, .failed:
            onRecognizerEnded()
        case .possible:
            break
        @unknown default:
            break
        }
    }

    func calculateScaleSnapOffsets(for childView: MovableView, threshold: CGFloat = 0.05) -> CGFloat? {
        if abs(childView.scale - 1) <= threshold {
            return 1
        }
        return nil
    }

    @objc
    func movableViewPanned(recognizer: UIPanGestureRecognizer) {
        guard let movableView = recognizer.view as? MovableView else { return }

        switch recognizer.state {
        case .began:
            onRecognizerBegan(view: movableView)
            originTransformations.position = movableView.position
        case .changed:
            let newPosition = originTransformations.position + recognizer.translation(in: self)
            // print("movableViewPanned newPosition : \(newPosition)")
            movableView.position = newPosition
            if let centerPointToSnap = calculateSnapOffsets(for: movableView, in: self) {
                movableView.position = centerPointToSnap
            }
        case .ended:
            onRecognizerEnded()
            movableView.onMove()
        case .cancelled, .failed:
            onRecognizerEnded()
        case .possible:
            break
        @unknown default:
            break
        }
    }

    func calculateSnapOffsets(for childView: MovableView, in parentView: UIView, threshold: CGFloat = 6) -> CGPoint? {
        //  guard childView.rotation == 0 else { return nil }

        // Ensure the parent's frame is in the same coordinate space as the child's
        let parentFrame = parentView.bounds
        let childFrame = childView.convert(childView.bounds, to: parentView)

        var offsetX: CGFloat = 0
        var offsetY: CGFloat = 0
        var shouldSnap = false

        /*    print("--parentFrame.center: \(parentFrame.center)")
         print("--childFrame.center: \(childFrame.center)")
         print("--parentFrame.origin: \(parentFrame.origin)")
         print("--childFrame.origin: \(childFrame.origin)")*/

        // Check center
        if abs(parentFrame.center.x - childFrame.center.x) <= threshold {
            offsetX = (parentFrame.center.x - childFrame.center.x) / 2
            shouldSnap = true
        }
        if abs(parentFrame.center.y - childFrame.center.y) <= threshold {
            offsetY = (parentFrame.center.y - childFrame.center.y) / 2
            shouldSnap = true
        }
        if isRotationVerticalOrHorizontal(for: childView) {
            // Check left edge
            if abs(childFrame.minX - parentFrame.minX) <= threshold {
                offsetX = parentFrame.minX - childFrame.minX
                shouldSnap = true
            }
            // Check right edge
            else if abs(childFrame.maxX - parentFrame.maxX) <= threshold {
                offsetX = parentFrame.maxX - childFrame.maxX
                shouldSnap = true
            }

            // Check top edge
            if abs(childFrame.minY - parentFrame.minY) <= threshold {
                offsetY = parentFrame.minY - childFrame.minY
                shouldSnap = true
            }
            // Check bottom edge
            else if abs(childFrame.maxY - parentFrame.maxY) <= threshold {
                offsetY = parentFrame.maxY - childFrame.maxY
                shouldSnap = true
            }
        }

        // Return the offset as CGPoint if snapping is needed
        return shouldSnap ? (CGPoint(x: offsetX, y: offsetY) + childView.position) : nil
    }

    @objc
    func movableViewLongPressed(recognizer: UILongPressGestureRecognizer) {
        guard let movableView = recognizer.view as? MovableView else { return }

        switch recognizer.state {
        case .began:
            onRecognizerBegan(view: movableView)
            // showOverlay(true)
            //  movableView.fadeOut()
            touchPosition = recognizer.touchLocations
        //  trashView.changeStatus(touchPosition)
        case .changed:
            touchPosition = recognizer.touchLocations
        //   trashView.changeStatus(touchPosition)
        case .ended, .cancelled, .failed:
            //  if trashView.contains(touchPosition) {
            //      movableView.remove()
            //  }
            //  else {
            //      movableView.fadeIn()
            //  }
            //  showOverlay(false)
            //   trashView.hide()
            onRecognizerEnded()
        case .possible:
            break
        @unknown default:
            break
        }
    }

    // Helper function to calculate distance
    func distance(from point1: CGPoint, to point2: CGPoint) -> CGFloat {
        sqrt(pow(point1.x - point2.x, 2) + pow(point1.y - point2.y, 2))
    }

    // MARK: - UIGestureRecognizerDelegate

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        let oneIsTapGesture = gestureRecognizer is UITapGestureRecognizer || otherGestureRecognizer is UITapGestureRecognizer
        return !oneIsTapGesture
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Prioritize gestures if needed (e.g., pan over pinch)
        /* if gestureRecognizer is UIPanGestureRecognizer && otherGestureRecognizer is UIPinchGestureRecognizer {
             return true
         }
         // Prioritize gestures if needed (e.g., pinch over rotate)
         if gestureRecognizer is UIRotationGestureRecognizer && otherGestureRecognizer is UIPanGestureRecognizer {
             return true
         }*/
        false
    }

    // MARK: - MovableViewDelegate

    /*
     func didTapTextView(movableView: MovableView, textView: StylableTextView) {
         UIView.animate(withDuration: Constants.animationDuration, animations: {
             movableView.goBackToOrigin()
         }, completion: { [weak self] _ in
             self?.delegate?.didTapTextView(options: textView.options, transformations: movableView.transformations)
             self?.selectedMovableView = movableView
         })
     }
      */

    func didTapImageView(movableView: MovableView, imageView: StylableImageView) {
        /* if let frontView = subviews.last, frontView != movableView {
             bringSubviewToFront(movableView)
         } else if let stickerImage = imageView.image {
             imageView.image = stickerImage.withHorizontallyFlippedOrientation()
         }*/
        if selectedMovableView == movableView {
            //    selectedMovableView?.layer.borderWidth = 0
            selectedMovableView = nil
        } else {
            selectedMovableView = movableView
            // selectedMovableView?.layer.borderWidth = 2
            // selectedMovableView?.layer.borderColor = UIColor.tintColor.cgColor
        }
    }

    /*  func didMoveTextView() {
         delegate?.didMoveText()
     }*/

    func didMoveImageView(_ imageView: StylableImageView) {
        delegate?.didMoveImage(imageView)
    }

    func didRemoveTextView() {
        delegate?.didRemoveText()
    }

    func didRemoveImageView(_ imageView: StylableImageView) {
        delegate?.didRemoveImage(imageView)
    }

    // MARK: - Private utilities

    /// shows or hides the overlay
    ///
    /// - Parameter show: true to show, false to hide
    /*  private func showOverlay(_ show: Bool) {
         UIView.animate(withDuration: Constants.animationDuration) {
             self.overlay.alpha = show ? 1 : 0
         }
     }*/

    // MARK: - Extended touch area

    private func onRecognizerBegan(view: MovableView) {
        if currentMovableView == nil {
            didBeginTouches(on: view)
        }
    }

    private func onRecognizerEnded() {
        guard let currentMovableView,
              let recognizers = currentMovableView.gestureRecognizers else { return }

        let allRecognizersAreInactive = recognizers.allSatisfy(\.isInactive)
        if allRecognizersAreInactive {
            didEndTouches()
        }
    }

    func didBeginTouches(on view: MovableView) {
        currentMovableView = view
        delegate?.didBeginTouchesOnMovableView()
    }

    func didEndTouches() {
        currentMovableView = nil
        delegate?.didEndTouchesOnMovableView()
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let currentMovableView {
            currentMovableView
        } else {
            super.hitTest(point, with: event)
        }
    }
}

// Extension for obtaining touch locations easily
extension UILongPressGestureRecognizer {
    fileprivate var touchLocations: [CGPoint] {
        var locations: [CGPoint] = []
        for touch in 0 ..< numberOfTouches {
            locations.append(location(ofTouch: touch, in: view?.superview))
        }

        return locations
    }
}
