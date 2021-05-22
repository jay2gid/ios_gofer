
import UIKit
import ImageIO
import Accelerate
import Photos

private var AssociatedObjectHandle: UInt8 = 0

// MARK: - SetImage
extension UIImageView {
    var stringProperty:String {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectHandle) as! String
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectHandle, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

// MARK: - Comeress images
extension UIImage {
    
    func getImageFromRect(frame: CGRect) -> UIImage {
        if let croppedImg = self.cgImage!.cropping(to: frame) {
            return UIImage(cgImage: croppedImg)
        }
        return self
    }
    
    func getSquareImage() -> UIImage {
        var xCord: CGFloat = 0
        var yCord: CGFloat = 0
        
        let diff = size.height - size.width
        if diff >= 0{
            // Change y cord
            yCord = CGFloat(diff / 2)
        }else{
            // chage in x cord
            xCord = CGFloat((diff * -1) / 2)
        }
        
        let heightWid = min(size.width, size.height)
        let origin =  CGPoint(x: xCord, y: yCord)
        let newSize = CGSize(width: heightWid, height: heightWid)
        if let croppedImg = self.cgImage!.cropping(to: CGRect(origin: origin, size: newSize)) {
            return UIImage(cgImage: croppedImg)
        }
        
        return self
    }
    
    func fixedOrientation() -> UIImage {
        if imageOrientation == .up {
            return self
        }
        
        var transform: CGAffineTransform = CGAffineTransform.identity
        
        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat.pi)
            break
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2.0)
            break
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat.pi / -2.0)
            break
        case .up, .upMirrored:
            break
        @unknown default:
            fatalError()
        }
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform.translatedBy(x: size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
            break
        case .leftMirrored, .rightMirrored:
            transform.translatedBy(x: size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        @unknown default:
            fatalError()
        }
        
        let ctx: CGContext = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: self.cgImage!.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        
        ctx.concatenate(transform)
        
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            break
        }
        
        return UIImage(cgImage: ctx.makeImage()!)
    }
    
    
    /// It will used to scale image size to down and maintain image ration.
    ///
    /// - Parameter toWidth: CGFloat type value, expect width
    /// - Returns: UIImage type object
    func scaleWithAspectRatioTo(_ width:CGFloat) -> UIImage {
        let oldWidth = size.width
        let oldHeight = size.height
        if oldHeight < width && oldWidth < width {
            return self
        }
        let scaleFactor = oldWidth > oldHeight ? width/oldWidth : width/oldHeight
        let newHeight = oldHeight * scaleFactor
        let newWidth = oldWidth * scaleFactor;
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    
    /// It will used to reduce image resolution and maintain aspect ratio.
    ///
    /// - Parameter width: Expected width to reduce resolution
    /// - Returns: UIImage object return
    func scaleAndManageAspectRatio(_ width: CGFloat) -> UIImage {
        if let cgImage = cgImage {
            let oldWidth = size.width
            let oldHeight = size.height
            if oldHeight < width && oldWidth < width {
                return self
            }
            let scaleFactor = oldWidth > oldHeight ? width/oldWidth : width/oldHeight
            let newHeight = oldHeight * scaleFactor
            let newWidth = oldWidth * scaleFactor;
            var format = vImage_CGImageFormat(bitsPerComponent: 8, bitsPerPixel: 32, colorSpace: nil, bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.first.rawValue),version: 0, decode: nil, renderingIntent: CGColorRenderingIntent.defaultIntent)
            var sourceBuffer = vImage_Buffer()
            defer {
                sourceBuffer.data.deallocate()
            }
            var error = vImageBuffer_InitWithCGImage(&sourceBuffer, &format, nil, cgImage, numericCast(kvImageNoFlags))
            guard error == kvImageNoError else { return self }
            
            // create a destination buffer
            let scale = self.scale
            let destWidth = Int(newWidth)
            let destHeight = Int(newHeight)
            let bytesPerPixel = cgImage.bitsPerPixel/8
            let destBytesPerRow = destWidth * bytesPerPixel
            let destData = UnsafeMutablePointer<UInt8>.allocate(capacity: destHeight * destBytesPerRow)
            defer {
                destData.deallocate()
            }
            var destBuffer = vImage_Buffer(data: destData, height: vImagePixelCount(destHeight), width: vImagePixelCount(destWidth), rowBytes: destBytesPerRow)
            
            // scale the image
            error = vImageScale_ARGB8888(&sourceBuffer, &destBuffer, nil, numericCast(kvImageHighQualityResampling))
            guard error == kvImageNoError else { return self }
            
            // create a CGImage from vImage_Buffer
            let destCGImage = vImageCreateCGImageFromBuffer(&destBuffer, &format, nil, nil, numericCast(kvImageNoFlags), &error)?.takeRetainedValue()
            guard error == kvImageNoError else { return self }
            
            // create a UIImage
            let imgOutPut = destCGImage.flatMap { (cgImage) -> UIImage? in
                return UIImage(cgImage: cgImage, scale: 0.0, orientation: imageOrientation)
            }
            return imgOutPut ?? self
        }else{
            return self
        }
    }
}


// MARK: - Get Image From asset
extension PHAsset {
    func getDisplayImage(size: CGSize, comp: @escaping (UIImage?) -> ()){
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        PHImageManager.default().requestImage(for: self, targetSize: size, contentMode: PHImageContentMode.aspectFill, options: requestOptions, resultHandler: { (image, info) -> Void in
            comp(image)
        })
    }
    
    func getFullImage(comp: @escaping (UIImage?) -> ()) {
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.isSynchronous = true
        PHImageManager.default().requestImage(for: self, targetSize: _maxImageSize, contentMode: PHImageContentMode.aspectFit, options: options, resultHandler: { (image, info) -> Void in
            comp(image)
        })
//        PHImageManager.default().requestImageData(for: self, options: options, resultHandler: { (imageData, imageDataUTI, imageOrientation, imageUserInfo) -> Void in
//            DispatchQueue.main.async(execute: { () -> Void in
//                if let d = imageData {
//                    let image = UIImage(data: d)
//                    comp(image)
//                } else {
//                    comp(nil)
//                }
//            })
//        })
    }
}
