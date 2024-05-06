import UIKit

class DashedLabel: UILabel {
    private enum Constants {
        static let cornerRadius: CGFloat = 4
        static let dashWidth: CGFloat = 1
        static let dashLength: CGFloat = 4
        static let dashSpaceLength: CGFloat = 4
        static let dashedPadding = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
    }

    var cornerRadius: CGFloat = Constants.cornerRadius {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }

    var dashWidth: CGFloat = Constants.dashWidth
    var dashLength: CGFloat = Constants.dashLength
    var dashSpaceLength: CGFloat = Constants.dashSpaceLength
    var dashedPadding: UIEdgeInsets = Constants.dashedPadding

    var dashColor: UIColor = .clear {
        didSet {
            dashedBorderLayer.strokeColor = dashColor.cgColor
        }
    }

    var dashedBorderLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = nil
        layer.isHidden = true
        return layer
    }()

    var showDashedBorder: Bool = false {
        didSet {
            dashedBorderLayer.isHidden = !showDashedBorder
            if showDashedBorder {
                updateDashedBorder()
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(dashedBorderLayer)

        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, _) in
                self.dashedBorderLayer.strokeColor = self.dashColor.cgColor
            }
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        dashedBorderLayer.frame = bounds
        dashedBorderLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #unavailable(iOS 17.0) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                dashedBorderLayer.strokeColor = dashColor.cgColor
            }
        }
    }

    func updateDashedBorder() {
        dashedBorderLayer.lineWidth = dashWidth
        dashedBorderLayer.lineDashPattern = [dashLength, dashSpaceLength] as [NSNumber]
    }

    override func drawText(in rect: CGRect) {
        if showDashedBorder {
            super.drawText(in: rect.inset(by: dashedPadding))
        } else {
            super.drawText(in: rect)
        }
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        guard showDashedBorder else {
            return size
        }
        return CGSize(
            width: size.width + dashedPadding.left + dashedPadding.right,
            height: size.height + dashedPadding.top + dashedPadding.bottom
        )
    }

    override var preferredMaxLayoutWidth: CGFloat {
        get {
            guard showDashedBorder else {
                return super.preferredMaxLayoutWidth
            }
            return bounds.width - (dashedPadding.left + dashedPadding.right)
        }
        set {
            super.preferredMaxLayoutWidth = newValue
        }
    }
}
