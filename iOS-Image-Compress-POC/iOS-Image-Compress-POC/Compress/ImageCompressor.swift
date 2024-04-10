//
//  ImageCompressor.swift
//  iOS-Image-Compress-POC
//
//  Created by Aiden.lee on 2024/04/10.
//

import UIKit

final class ImageCompressor {
  func compress(image: UIImage, type: CompressType, quality: CGFloat) -> (TimeInterval, Data?) {
    switch type {
    case .jpeg: return compressToJpeg(image: image, quality: quality)
    case .png: return compressToPng(image: image)
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

  private func progressTime(_ closure: () -> Data?) -> (TimeInterval, Data?) {
    let start = CFAbsoluteTimeGetCurrent()
    let data = closure()
    let diff = CFAbsoluteTimeGetCurrent() - start
    return (diff, data)
  }
}
