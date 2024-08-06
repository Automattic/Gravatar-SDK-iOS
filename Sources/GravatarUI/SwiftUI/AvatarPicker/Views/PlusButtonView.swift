import SwiftUI

struct PlusButtonView: View {
    let sizeRange: ClosedRange<CGFloat>
    let cornerRadius: CGFloat

    init(minSize: CGFloat, maxSize: CGFloat, cornerRadius: CGFloat = 4) {
        self.sizeRange = minSize ... maxSize
        self.cornerRadius = cornerRadius
    }

    public var body: some View {
        Image(systemName: "plus")
            .font(.system(size: 44, weight: .light))
            .foregroundColor(Color(uiColor: UIColor.systemGray2))
            .frame(
                minWidth: sizeRange.lowerBound,
                maxWidth: sizeRange.upperBound,
                minHeight: sizeRange.lowerBound,
                maxHeight: sizeRange.upperBound
            )
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color(UIColor.systemGray2), style: StrokeStyle(lineWidth: 2, dash: [7]))
            )
    }
}

#Preview {
    PlusButtonView(minSize: 80, maxSize: 80)
}

#Preview("Dark Mode") {
    PlusButtonView(minSize: 80, maxSize: 80)
        .preferredColorScheme(.dark)
}
