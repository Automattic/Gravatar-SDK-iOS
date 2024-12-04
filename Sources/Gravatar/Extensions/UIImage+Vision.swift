import UIKit
@preconcurrency import Vision
import CoreImage
import CoreImage.CIFilterBuiltins

extension UIImage {

    public func replaceBackground(with newBackground: UIImage, completion: @escaping @Sendable (UIImage?) -> Void) {
        let inputImage = self
        guard let cgImage = inputImage.cgImage else {
            completion(nil)
            return
        }

        // Create a Vision request for person segmentation
        let request = VNGeneratePersonSegmentationRequest()
        request.revision = VNGeneratePersonSegmentationRequestRevision1
        request.qualityLevel = .accurate
        request.outputPixelFormat = kCVPixelFormatType_OneComponent8
        #if targetEnvironment(simulator)
        if #available(iOS 17.0, *) {
          let allDevices = MLComputeDevice.allComputeDevices

          for device in allDevices {
            if(device.description.contains("MLCPUComputeDevice")){
              request.setComputeDevice(.some(device), for: .main)
              break
            }
          }
        } else {
          // Fallback on earlier versions
          request.usesCPUOnly = true
        }
        #endif

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        //DispatchQueue.global(qos: .userInitiated).async { [weak self] in
          //  guard let self else { return }
            do {
                try handler.perform([request])
                
                guard let mask = request.results?.first else {
                    completion(nil)
                    return
                }
                let maskBuffer = mask.pixelBuffer
                let newImage = self.putBackground(withMask: maskBuffer, newBackground: newBackground)
               // DispatchQueue.main.async {
                    completion(newImage)
               // }
            } catch {
                print("Error performing segmentation: \(error)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
      //  }
    }

    private func putBackground(withMask maskBuffer: CVPixelBuffer, newBackground background: UIImage) -> UIImage? {
        guard let input = CIImage(image: self),
              let background = CIImage(image: background) else { return nil }
        let mask = CIImage(cvPixelBuffer: maskBuffer)

        let maskScaleX = input.extent.width / mask.extent.width
        let maskScaleY = input.extent.height / mask.extent.height
        let maskScaled = mask.transformed(by: __CGAffineTransformMake(maskScaleX, 0, 0, maskScaleY, 0, 0))

        let backgroundScaleX = input.extent.width / background.extent.width
        let backgroundScaleY = input.extent.height / background.extent.height
        let backgroundScaled = background.transformed(by: __CGAffineTransformMake(backgroundScaleX, 0, 0, backgroundScaleY, 0, 0))

        let blendFilter = CIFilter.blendWithRedMask()
        blendFilter.inputImage = input
        blendFilter.backgroundImage = backgroundScaled
        blendFilter.maskImage = maskScaled

        guard let output = blendFilter.outputImage else { return nil }
        return UIImage(ciImage: output, scale: self.scale, orientation: self.imageOrientation)
    }
}
