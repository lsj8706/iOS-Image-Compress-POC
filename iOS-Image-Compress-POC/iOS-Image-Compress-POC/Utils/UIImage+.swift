//
//  UIImage+.swift
//  iOS-Image-Compress-POC
//
//  Created by Aiden.lee on 2024/04/11.
//

import UIKit

// MARK: - Resize

extension UIImage {

  func resizedImage(
    _ newSize: CGSize,
    interpolationQuality quality: CGInterpolationQuality
  ) -> UIImage {

    var isDrawTransposed: Bool

    switch(self.imageOrientation) {
    case .left, .leftMirrored, .right, .rightMirrored:
      isDrawTransposed = true
    default:
      isDrawTransposed = false
    }

    return self.resizedImage(
      newSize,
      transform: self.transformForOrientation(newSize),
      drawTransposed: isDrawTransposed,
      interpolationQuality: quality
    )
  }

  fileprivate func normalizeBitmapInfo(_ bitMapInfo: CGBitmapInfo) -> UInt32 {
    var alphaInfo: UInt32 = bitMapInfo.rawValue & CGBitmapInfo.alphaInfoMask.rawValue

    if alphaInfo == CGImageAlphaInfo.last.rawValue {
      alphaInfo = CGImageAlphaInfo.premultipliedLast.rawValue
    }

    if alphaInfo == CGImageAlphaInfo.first.rawValue {
      alphaInfo = CGImageAlphaInfo.premultipliedFirst.rawValue
    }

    var newBI: UInt32 = bitMapInfo.rawValue & ~CGBitmapInfo.alphaInfoMask.rawValue
    newBI |= alphaInfo
    return newBI
  }

  fileprivate func resizedImage(
    _ newSize: CGSize,
    transform: CGAffineTransform,
    drawTransposed isTranspose: Bool,
    interpolationQuality quality: CGInterpolationQuality
  ) -> UIImage {

    let newRect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height).integral
    let transposedRect = CGRect(x: 0, y: 0, width: newRect.size.height, height: newRect.size.width)

    guard let imageRef: CGImage = self.cgImage,
      let colorSpace = imageRef.colorSpace else { return self }

    // Build a context that's the same dimensions as the new size
    guard let bitmap: CGContext = CGContext(
      data: nil,
      width: Int(newRect.size.width),
      height: Int(newRect.size.height),
      bitsPerComponent: imageRef.bitsPerComponent,
      bytesPerRow: 0,
      space: colorSpace,
      bitmapInfo: normalizeBitmapInfo(imageRef.bitmapInfo)
      ) else { return self }

    // Rotate and/or flip the image if required by its orientation
    bitmap.concatenate(transform)

    // Set the quality level to use when rescaling
    bitmap.interpolationQuality = quality

    // Draw into the context; this scales the image
    bitmap.draw(imageRef, in: isTranspose ? transposedRect: newRect)

    // Get the resized image from the context and a UIImage
    guard let newImageRef: CGImage = bitmap.makeImage() else { return self }
    return UIImage(cgImage: newImageRef)
  }

  fileprivate func transformForOrientation(_ newSize: CGSize) -> CGAffineTransform {
    var transform: CGAffineTransform = CGAffineTransform.identity

    switch (self.imageOrientation) {
    case .down, .downMirrored:
      // EXIF = 3 / 4
      transform = transform.translatedBy(x: newSize.width, y: newSize.height)
      transform = transform.rotated(by: .pi)
    case .left, .leftMirrored:
      // EXIF = 6 / 5
      transform = transform.translatedBy(x: newSize.width, y: 0)
      transform = transform.rotated(by: .pi / 2)
    case .right, .rightMirrored:
      // EXIF = 8 / 7
      transform = transform.translatedBy(x: 0, y: newSize.height)
      transform = transform.rotated(by: -.pi / 2)
    default:
      break
    }

    switch(self.imageOrientation) {
    case .upMirrored, .downMirrored:
      // EXIF = 2 / 4
      transform = transform.translatedBy(x: newSize.width, y: 0)
      transform = transform.scaledBy(x: -1, y: 1)
    case .leftMirrored, .rightMirrored:
      // EXIF = 5 / 7
      transform = transform.translatedBy(x: newSize.height, y: 0)
      transform = transform.scaledBy(x: -1, y: 1)
    default:
      break
    }

    return transform
  }
}
