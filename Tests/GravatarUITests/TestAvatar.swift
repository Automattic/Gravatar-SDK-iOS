import GravatarUI
import UIKit

class TestAvatarImageView: UIImageView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    func applyStyle() {
        widthAnchor.constraint(equalToConstant: 80).isActive = true
        heightAnchor.constraint(equalToConstant: 80).isActive = true
        layer.cornerRadius = 10
        layer.borderColor = UIColor.green.withAlphaComponent(0.5).cgColor
        layer.borderWidth = 2
        backgroundColor = UIColor.purple.withAlphaComponent(0.5)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TestAvatarImageViewWrapper: UIView, ImageViewWrapper {
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    var baseView: UIView {
        self
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        baseView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        baseView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        baseView.translatesAutoresizingMaskIntoConstraints = false
        baseView.backgroundColor = .blue.withAlphaComponent(0.2)
        baseView.layer.cornerRadius = 20
        imageView.widthAnchor.constraint(equalTo: baseView.widthAnchor, multiplier: 0.8).isActive = true
        imageView.heightAnchor.constraint(equalTo: baseView.heightAnchor, multiplier: 0.8).isActive = true
        imageView.centerXAnchor.constraint(equalTo: baseView.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: baseView.centerYAnchor).isActive = true
        imageView.backgroundColor = .blue.withAlphaComponent(0.5)
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.green.withAlphaComponent(0.5).cgColor
        imageView.layer.cornerRadius = 20
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TestCustomAvatarView: UIView, AvatarProviding {
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(stackView)
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.purple.withAlphaComponent(0.1)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Avatar Text"
        return label
    }()

    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 10
        imageView.layer.borderColor = UIColor.green.withAlphaComponent(0.5).cgColor
        imageView.layer.borderWidth = 2
        imageView.backgroundColor = .blue.withAlphaComponent(0.2)
        return imageView
    }()

    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageView, label])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
    }()

    var avatarView: UIView {
        self
    }

    func setImage(with source: URL?, placeholder: UIImage?, options: [GravatarUI.ImageSettingOption]?, completion: ((Bool) -> Void)?) {}

    func setImage(_: UIImage?) {}

    func refresh(with paletteType: GravatarUI.PaletteType) {}
}
