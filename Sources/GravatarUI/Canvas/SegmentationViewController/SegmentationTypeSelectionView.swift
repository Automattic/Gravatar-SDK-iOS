import UIKit

class SegmentationTypeSelectionView: UIStackView {
    // A callback that fires when user taps a new item
    var onSelectionChanged: ((SegmentationOption) -> Void)?

    private var itemViews: [SegmentationOptionView] = []
    private(set) var selectedType: SegmentationType?

    init(options: [SegmentationOption]) {
        super.init(frame: .zero)
        self.axis = .horizontal
        self.alignment = .fill
        self.distribution = .fillEqually
        self.spacing = 8

        setupItems(options: options)
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupItems(options: [SegmentationOption]) {
        for opt in options {
            let itemView = SegmentationOptionView(option: opt)
            itemView.translatesAutoresizingMaskIntoConstraints = false

            // Tap gesture: when tapped, we select that item
            let tap = UITapGestureRecognizer(target: self, action: #selector(itemTapped(_:)))
            itemView.addGestureRecognizer(tap)
            itemView.isUserInteractionEnabled = true

            itemViews.append(itemView)
            addArrangedSubview(itemView)
        }
    }

    @objc
    private func itemTapped(_ gesture: UITapGestureRecognizer) {
        guard let tappedView = gesture.view as? SegmentationOptionView else { return }

        // Mark old selection as false
        if let prevType = selectedType,
           let prevView = itemViews.first(where: { $0.option.type == prevType })
        {
            prevView.isOptionSelected = false
        }

        // Mark new selection
        selectedType = tappedView.option.type
        tappedView.isOptionSelected = true

        // Notify external
        onSelectionChanged?(tappedView.option)
    }

    /// Programmatically select a type if needed
    func selectType(_ type: SegmentationType) {
        // Deselect current
        if let prevType = selectedType,
           let prevView = itemViews.first(where: { $0.option.type == prevType })
        {
            prevView.isOptionSelected = false
        }

        // Find the matching view
        if let newView = itemViews.first(where: { $0.option.type == type }) {
            newView.isOptionSelected = true
        }
        selectedType = type
    }
}
