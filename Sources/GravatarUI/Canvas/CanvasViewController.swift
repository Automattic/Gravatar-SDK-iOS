import UIKit

public class CanvasViewController: UIViewController {
    private let canvasView = MovableViewCanvas()
    private let canvasHoleView = UIView() // UIVisualEffectView()
    private var imageViews: [UIImageView] = []
    let inputImage: UIImage
    var onCompletion: ((UIImage) -> Void)?
    var onCancel: (() -> Void)?

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

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // Action for Cancel button
    @objc
    func cancelButtonTapped() {
        onCancel?()
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
        canvasHoleView.translatesAutoresizingMaskIntoConstraints = false
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        canvasView.layer.borderColor = UIColor.white.cgColor
        canvasView.layer.borderWidth = 1
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
        ])
        canvasView.backgroundColor = UIColor.label.withAlphaComponent(0.1)

        // Add masking effect
        addCanvasHoleMask()
        view.bringSubviewToFront(doneButton)
        view.bringSubviewToFront(cancelButton)
        // Add gesture recognizer for image addition
        // let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addImage))
        //  canvasView.addGestureRecognizer(tapGesture)
        addImageLayer()
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

    func addImageLayer() {
        let imageView = StylableImageView(id: UUID().uuidString, image: inputImage)
        //  imageView.translatesAutoresizingMaskIntoConstraints = false
        //  imageView.image = inputImage
        imageView.contentMode = .scaleAspectFit
        let size: CGSize
        let aspectRatio = inputImage.size.width / inputImage.size.height
        if inputImage.size.width > inputImage.size.height {
            size = .init(width: canvasView.frame.height * aspectRatio, height: canvasView.frame.height)
        } else {
            size = .init(width: canvasView.frame.width, height: canvasView.frame.width / aspectRatio)
        }
        canvasView.addView(
            view: imageView,
            transformations: ViewTransformations(),
            location: canvasView.bounds.center,
            size: size,
            animated: true
        )
        /*    let borderView = UIView()
         borderView.translatesAutoresizingMaskIntoConstraints = false
         borderView.isUserInteractionEnabled = true

         borderView.backgroundColor = .clear
         borderView.layer.borderColor = UIColor.tintColor.cgColor
         borderView.layer.borderWidth = 2
         borderView.layer.cornerRadius = 4
         borderView.layer.zPosition = 10

         canvasHoleView.addSubview(borderView)
         NSLayoutConstraint.activate([
             borderView.widthAnchor.constraint(equalTo: imageView.widthAnchor, constant: 3),
             borderView.heightAnchor.constraint(equalTo: imageView.heightAnchor, constant: 3),
             borderView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
             borderView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
         ])
         canvasHoleView.bringSubviewToFront(borderView)
         */
        /*
         let imageView = UIImageView()
         imageView.translatesAutoresizingMaskIntoConstraints = false
         imageView.isUserInteractionEnabled = true
         imageView.image = inputImage
         imageView.contentMode = .scaleAspectFit
         let borderView = UIView()
         borderView.translatesAutoresizingMaskIntoConstraints = false
         borderView.isUserInteractionEnabled = true

         borderView.backgroundColor = .clear
         borderView.layer.borderColor = UIColor.tintColor.cgColor
         borderView.layer.borderWidth = 2
         borderView.layer.cornerRadius = 4
         borderView.layer.zPosition = 10

         canvasHoleView.addSubview(borderView)

         let aspectRatio = inputImage.size.width / inputImage.size.height

         view.addSubview(imageView)
         imageViews.append(imageView)

         if inputImage.size.width > inputImage.size.height {
             imageView.heightAnchor.constraint(equalTo: canvasView.heightAnchor).isActive = true
             imageView.widthAnchor.constraint(equalTo: canvasView.heightAnchor, multiplier: aspectRatio).isActive = true
         }
         else {
             imageView.widthAnchor.constraint(equalTo: canvasView.widthAnchor).isActive = true
             imageView.heightAnchor.constraint(equalTo: canvasView.heightAnchor, multiplier: 1 / aspectRatio).isActive = true
         }
         NSLayoutConstraint.activate([
             imageView.centerXAnchor.constraint(equalTo: canvasView.centerXAnchor),
             imageView.centerYAnchor.constraint(equalTo: canvasView.centerYAnchor),
             borderView.widthAnchor.constraint(equalTo: imageView.widthAnchor, constant: 3),
             borderView.heightAnchor.constraint(equalTo: imageView.heightAnchor, constant: 3),
             borderView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
             borderView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
         ])
         view.bringSubviewToFront(canvasHoleView)
         canvasHoleView.bringSubviewToFront(borderView)
         */
    }
}
