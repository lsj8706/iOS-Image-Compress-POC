//
//  ImageCompressor.swift
//  iOS-Image-Compress-POC
//
//  Created by Aiden.lee on 2024/04/10.
//

import UIKit
import SDWebImageWebPCoder
import WebP

final class ImageCompressor {
  func compress(image: UIImage, type: CompressType, quality: CGFloat) -> (TimeInterval, Data?) {
    switch type {
    case .jpeg: return compressToJpeg(image: image, quality: quality)
    case .png: return compressToPng(image: image)
    case .webp: return compressToWebpWithSDWebImage(image: image, quality: quality)
    }
  }

  private func compressToJpeg(image: UIImage, quality: CGFloat) -> (TimeInterval, Data?) {
    progressTime {
      image.jpegData(compressionQuality: quality)
    }
  }

  private func compressToPng(image: UIImage) -> (TimeInterval, Data?) {
    progressTime {
      image.pngData()
    }
  }

  private func compressToWebpWithSDWebImage(image: UIImage, quality: CGFloat) -> (TimeInterval, Data?) {
    progressTime {
      let encoder = SDImageWebPCoder.shared
      let quality = Float(quality)
      let data = encoder.encodedData(
        with: image,
        format: .webP,
        options: [
          .encodeCompressionQuality: quality,
          .encodeFirstFrameOnly: true,
          .encodeWebPMethod: NSNumber(value: 0),
          .encodeWebPThreadLevel: 0,
          .encodeWebPPass: NSNumber(value: 1),
          .encodeWebPLossless: false,
          .encodeWebPPreprocessing: false,
          .encodeBackgroundColor: UIColor.white,
        ]
      )
      return data
    }
  }

  private func compressToWebp(image: UIImage, quality: CGFloat) -> (TimeInterval, Data?) {
    progressTime {
      let encoder = WebPEncoder()
      let data = try? encoder.encode(image, config: .preset(.picture, quality: Float(quality*100)))
      return data
    }
  }

  private func progressTime(_ closure: () -> Data?) -> (TimeInterval, Data?) {
    let start = DispatchTime.now()
    let data = closure()
    let end = DispatchTime.now()
    let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
    return (Double(nanoTime) / 1_000_000_000, data)
  }
}
