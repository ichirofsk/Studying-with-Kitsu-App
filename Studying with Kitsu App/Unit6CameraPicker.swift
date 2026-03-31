import SwiftUI
import UIKit

public struct Unit6CameraPicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) private var presentationMode
    public var onImagePicked: (UIImage?) -> Void

    public init(onImagePicked: @escaping (UIImage?) -> Void) {
        self.onImagePicked = onImagePicked
    }

    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            picker.delegate = context.coordinator
            return picker
        }

        picker.sourceType = .camera
        if UIImagePickerController.isCameraDeviceAvailable(.front) {
            picker.cameraDevice = .front
        }
        picker.allowsEditing = false
        picker.delegate = context.coordinator
        return picker
    }

    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // No update needed
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: Unit6CameraPicker

        public init(_ parent: Unit6CameraPicker) {
            self.parent = parent
        }

        public func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let image = info[.originalImage] as? UIImage
            parent.onImagePicked(image)
            parent.presentationMode.wrappedValue.dismiss()
        }

        public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onImagePicked(nil)
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
