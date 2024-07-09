import UIKit

class AvatarCollectionViewCell: UICollectionViewCell {
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 4
        imageView.layer.masksToBounds = true
        return imageView
    }()

    let loadingIndicator = UIActivityIndicatorView(style: .medium)

    var isLoading: Bool {
        get {
            loadingIndicator.isAnimating
        }
        set {
            if newValue {
                loadingIndicator.startAnimating()
                imageView.alpha = 0.7
            } else {
                loadingIndicator.stopAnimating()
                UIView.animate(withDuration: 0.2) {
                    self.imageView.alpha = 1
                }
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            loadingIndicator.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
        ])
    }

    override var isSelected: Bool {
        didSet {
            guard oldValue != isSelected else { return }
            self.imageView.layer.borderWidth = 4
            self.imageView.layer.borderColor = UIColor.clear.cgColor
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0) {
                self.imageView.layer.borderColor = self.isSelected ? self.tintColor.cgColor : UIColor.clear.cgColor
            }
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
