//
//  ImageCompressor.swift
//  iOS-Image-Compress-POC
//
//  Created by Aiden.lee on 2024/04/10.
//

import UIKit

final class ImageCompressor {
  func compress(image: UIImage, type: CompressType, quality: CGFloat) -> Data? {
    switch type {
    case .jpeg: return compressToJpeg(image: image, quality: quality)
    case .png: return compressToPng(image: image)
    }
  }

  private func compressToJpeg(image: UIImage, quality: CGFloat) -> Data? {
    image.jpegData(compressionQuality: quality)
  }

  private func compressToPng(image: UIImage) -> Data? {
    image.pngData()
  }
}
