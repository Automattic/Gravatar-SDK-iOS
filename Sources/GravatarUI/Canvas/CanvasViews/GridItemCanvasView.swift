import SwiftUI
import UIKit

struct GridItemCanvasView: UIViewRepresentable {
    static let length: CGFloat = 125

    var imageTemplate: ImageTemplate

    func makeUIView(context: Context) -> UIView {
        let myView = MovableViewCanvas()
        myView.isUserInteractionEnabled = false
        myView.translatesAutoresizingMaskIntoConstraints = false
        myView.backgroundColor = .gray
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: Self.length, height: Self.length))
        containerView.addSubview(myView) // Add it to a superview so the canvas can have size
        myView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            myView.widthAnchor.constraint(equalToConstant: Self.length),
            myView.heightAnchor.constraint(equalToConstant: Self.length),
            myView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            myView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
        ])

        containerView.setNeedsLayout()
        containerView.layoutIfNeeded()

        myView.addLayers(imageTemplate.template, personImage: imageTemplate.image)

        return containerView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Update logic (if needed)
    }
}
