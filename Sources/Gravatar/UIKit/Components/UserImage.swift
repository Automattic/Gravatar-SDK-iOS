import UIKit

public class UserImageView: UIView {
    let imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    public init() {
        super.init(frame: .zero)
        configureUI()
    }

    @discardableResult
    public func setImage(
        email: String,
        placeholder: UIImage? = nil,
        rating: ImageRating? = nil,
        preferredSize: CGSize? = nil,
        defaultImageOption: DefaultImageOption? = nil,
        options: [ImageSettingOption]? = nil,
        completionHandler: ImageSetCompletion? = nil
    ) -> CancellableDataTask? {
        imageView.gravatar.setImage(
            email: email,
            placeholder: placeholder,
            preferredSize: preferredSize,
            defaultImageOption: defaultImageOption,
            options: options
        )
    }

    @discardableResult
    public func setImage(
        with source: URL?,
        placeholder: UIImage? = nil,
        options: [ImageSettingOption]? = nil,
        completionHandler: ImageSetCompletion? = nil
    ) -> CancellableDataTask? {
        imageView.gravatar.setImage(
            with: source,
            placeholder: placeholder,
            options: options,
            completionHandler: completionHandler
        )
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
    }

    func configureUI() {
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        layer.masksToBounds = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
