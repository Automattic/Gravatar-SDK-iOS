import Foundation
import SwiftUI

/// Describes an image editor to be used after picking the image from photo picker.
/// Caution: The output needs to be a square image otherwise the Gravatar backend will not accept it.
public protocol ImageEditorView: View {
    /// The image to edit.
    var inputImage: UIImage { get }

    /// Callback to call when the editing is done. Pass the edited image here..
    var editingDidFinish: (UIImage) -> Void { get set }
}

public typealias ImageEditorBlock<ImageEditor: ImageEditorView> = (UIImage, _ editingDidFinish: @escaping (UIImage) -> Void) -> ImageEditor

/// A type to use to help the compiler resolve the generic type when the custom image editor needs to be passed as `nil`.
public struct NoCustomEditor: ImageEditorView {
    public var inputImage: UIImage

    public var editingDidFinish: (UIImage) -> Void

    public var body: some View {
        EmptyView()
    }
}

/// A type to use to help the compiler resolve the generic type when the custom image editor needs to be passed as `nil`.
public typealias NoCustomEditorBlock = (UIImage, _ editingDidFinish: @escaping (UIImage) -> Void) -> NoCustomEditor
