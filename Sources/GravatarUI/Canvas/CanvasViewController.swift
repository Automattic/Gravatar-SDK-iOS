import Combine
import SwiftUI
import UIKit

enum Layer {
    static let background: String = SDKLocalizedString("Background", comment: "Name of the background layer in an image editor")
    static let image: String = SDKLocalizedString("Image layer", comment: "Name of the image layer in an image editor")
}

public class CanvasViewController: UIViewController {
    private let canvasView = MovableViewCanvas()
    private let canvasHoleView = UIView() // UIVisualEffectView()
    private var imageViews: [UIImageView] = []
    private lazy var personSegmentationModel = PersonSegmentationModel()

    let inputImage: UIImage
    let inputImageID = UUID().uuidString
    var onCompletion: ((UIImage) -> Void)?
    var onCancel: (() -> Void)?
    private var cancellables = Set<AnyCancellable>()

    private lazy var cancelButton: UIButton = {
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        return cancelButton
    }()

    private lazy var doneButton: UIButton = {
        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        return doneButton
    }()

    private lazy var cutoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cutout", for: .normal)
        button.setImage(UIImage(systemName: "scissors"), for: .normal)
        button.addTarget(self, action: #selector(cutoutButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    public init(inputImage: UIImage, onCompletion: ((UIImage) -> Void)?, onCancel: (() -> Void)?) {
        self.inputImage = inputImage
        self.onCancel = onCancel
        self.onCompletion = onCompletion
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public var prefersStatusBarHidden: Bool { true }

    var segmentationType: SegmentationType = .foreground
    override public func viewDidLoad() {
        super.viewDidLoad()
        decodeTemplates()
        setupUI()
        listenForUpdates()
        Task {
            do {
                self.segmentationType = await personSegmentationModel.suggestedSegmentationType(for: inputImage, cacheKey: inputImageID)
                try await personSegmentationModel.runSegmentationRequestOnImage(inputImage, for: segmentationType, cacheKey: inputImageID)
            } catch {
                print("Error running request: \(error)")
            }
        }
        decodeTemplates()
    }

    var templates: [CanvasLayers] = []
    func decodeTemplates() {
        templates = CanvasLayersParser.decodeAllTemplates()
    }

    func listenForUpdates() {
        personSegmentationModel.$segmentedImageMap.sink { [weak self] imageMap in
            guard let self else { return }
            let key = SegmentationResultKey(imageKey: inputImageID, segmentationType: segmentationType)
            let image = imageMap[key]?.croppedResultImage
            print(image?.size ?? "nil")
            if let image, let template = templates.first {
                canvasView.addLayers(template, personImage: image)
            }
        }
        .store(in: &cancellables)
    }

    // Action for Cancel button
    @objc
    func cancelButtonTapped() {
        onCancel?()
    }

    @objc
    func cutoutButtonTapped() {
        let controller = UIHostingController(
            rootView: SegmentationView(
                segmentationType: segmentationType,
                viewModel: personSegmentationModel,
                inputImage: inputImage,
                inputImageID: inputImageID,
                onDone: {
                    self.presentedViewController?.dismiss(animated: true)
                },
                onCancel: {
                    self.presentedViewController?.dismiss(animated: true)
                }
            )
        )
        present(controller, animated: true)
    }

    // Action for Done button
    @objc
    func doneButtonTapped() {
        if let image = canvasView.snapshotImage() {
            onCompletion?(image)
        }
    }

    private func setupUI() {
        view.addSubview(cancelButton)
        view.addSubview(doneButton)
        view.backgroundColor = .black
        // let blurEffect = UIBlurEffect(style: .systemThinMaterialDark)

        // canvasHoleView.effect = blurEffect
        canvasHoleView.backgroundColor = .black
        canvasHoleView.isUserInteractionEnabled = false
        canvasHoleView.alpha = 0.9
        view.addSubview(canvasView)
        view.addSubview(canvasHoleView)
        view.addSubview(cutoutButton)
        canvasHoleView.translatesAutoresizingMaskIntoConstraints = false
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        canvasView.layer.borderColor = UIColor.white.cgColor
        // canvasView.layer.borderWidth = 1
        NSLayoutConstraint.activate([
            canvasHoleView.topAnchor.constraint(equalTo: view.topAnchor),
            canvasHoleView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            canvasHoleView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            canvasHoleView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            canvasView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            canvasView.widthAnchor.constraint(equalToConstant: 300),
            canvasView.heightAnchor.constraint(equalToConstant: 300),
            canvasView.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // Cancel button - Left of the screen, within safe area
            cancelButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            cancelButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),

            // Done button - Right of the screen, within safe area
            doneButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            doneButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            cutoutButton.leadingAnchor.constraint(equalTo: canvasView.leadingAnchor),
            cutoutButton.topAnchor.constraint(equalTo: canvasView.bottomAnchor, constant: 12),
        ])

        canvasView.backgroundColor = UIColor.label.withAlphaComponent(0.1)

        // Add masking effect
        addCanvasHoleMask()
        view.bringSubviewToFront(doneButton)
        view.bringSubviewToFront(cancelButton)
        view.bringSubviewToFront(cutoutButton)
        // Add gesture recognizer for image addition
        // let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addImage))
        //  canvasView.addGestureRecognizer(tapGesture)
    }

    private func addCanvasHoleMask() {
        let maskLayer = CAShapeLayer()
        maskLayer.frame = view.bounds

        // Define the mask path
        let path = UIBezierPath(rect: view.bounds)
        view.layoutIfNeeded()
        let canvasHolePath = UIBezierPath(rect: canvasView.frame)
        path.append(canvasHolePath)
        path.usesEvenOddFillRule = true

        maskLayer.path = path.cgPath
        maskLayer.fillRule = .evenOdd

        canvasHoleView.layer.mask = maskLayer
    }
}
