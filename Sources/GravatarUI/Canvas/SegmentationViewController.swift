import Combine
import UIKit

class SegmentationViewController: UIViewController {
    let personSegmentationModel: PersonSegmentationModel
    let inputImage: UIImage
    var onCompletion: ((UIImage) -> Void)?
    var onCancel: (() -> Void)?

    private lazy var selectionView: SegmentationTypeSelectionView = {
        let options = SegmentationOption.makeSegmentationOptions()
        let view = SegmentationTypeSelectionView(options: options)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        if let checkerboardImage = UIImage(named: "checkerboard16x16") {
            let backgroundPattern = UIColor(patternImage: checkerboardImage)
            view.backgroundColor = backgroundPattern
        }
        return view
    }()

    init(personSegmentationModel: PersonSegmentationModel, inputImage: UIImage) {
        self.personSegmentationModel = personSegmentationModel
        self.inputImage = inputImage
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(imageView)
        view.addSubview(selectionView)
        
        // 3) Handle selection changes
        selectionView.onSelectionChanged = { [weak self] option in
            self?.segmentationTypeDidChange(to: option)
        }

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: .DS.Padding.double),
            imageView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: .DS.Padding.double),
            imageView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -CGFloat.DS.Padding.double),
           // imageView.widthAnchor.constraint(lessThanOrEqualToConstant: 400),
            imageView.widthAnchor.constraint(greaterThanOrEqualToConstant: 300),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            selectionView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: CGFloat.DS.Padding.medium),
            selectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: CGFloat.DS.Padding.double),
            selectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -CGFloat.DS.Padding.double),
            //selectionView.heightAnchor.constraint(equalToConstant: 50)

        ])
    }
    
    private func segmentationTypeDidChange(to newOption: SegmentationOption) {
        // Update UI or run new segmentation logic...
        switch newOption.type {
        case .foreground:
            imageView.image = UIImage(systemName: "person.crop.circle.badge.plus")
        case .people:
            imageView.image = UIImage(systemName: "person.3.fill")
        case .personInstance:
            imageView.image = UIImage(systemName: "person.fill.viewfinder")
        }
        print("Selected: \(newOption.title)")
    }
}
