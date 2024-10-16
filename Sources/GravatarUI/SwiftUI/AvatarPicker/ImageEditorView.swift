import Foundation
import SwiftUI

/// Describes an image editor to be used after picking the image from the photo picker.
/// Caution: The output needs to be a square image; otherwise, the Gravatar backend will not accept it.
public protocol ImageEditorView: View {
    /// The image to edit.
    var inputImage: UIImage { get }

    /// Callback to call when the editing is done. Pass the edited image here.
    var editingDidFinish: @Sendable (UIImage) -> Void { get set }
}

public typealias ImageEditorBlock<ImageEditor: ImageEditorView> = (UIImage, _ editingDidFinish: @escaping @Sendable (UIImage) -> Void) -> ImageEditor

/// Because of how generics work, the compiler must resolve the image editor's concrete type.
/// When its value is `nil` though, the compiler can't resolve the concrete type, and it complains. This type here is used to make the compiler happy when the
/// passed value is `nil`.
public struct NoCustomEditor: ImageEditorView {
    public var inputImage: UIImage
    public var editingDidFinish: @Sendable (UIImage) -> Void

    public var body: some View {
        EmptyView()
    }
}

/// This exists for the same reason with `NoCustomEditor`.
public typealias NoCustomEditorBlock = (UIImage, _ editingDidFinish: @escaping (UIImage) -> Void) -> NoCustomEditor
