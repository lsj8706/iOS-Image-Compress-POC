//
//  ImageResizer.swift
//  iOS-Image-Compress-POC
//
//  Created by Aiden.lee on 2024/04/11.
//

import UIKit

final class ImageResizer {
  private enum Const {
    static let uploadImageSize = CGSize(width: 1920, height: 1920)
  }

  /// 업로드를 위해 사전에 정의한 이미지 최대 사이즈에 맞추어 resizing을 수행해요.
  func process(_ image: UIImage) -> UIImage {
    let newSize = sizeWithAspectRatio(image.size)
    let resizedImage = image.resizedImage(newSize, interpolationQuality: .high)
    return resizedImage
  }

  private func sizeWithAspectRatio(_ size: CGSize) -> CGSize {
    let maxPixel = Const.uploadImageSize.width
    let aspectRatio = size.width / size.height

    if aspectRatio > 1 {
      return CGSize(width: maxPixel, height: maxPixel / aspectRatio)
    }

    return CGSize(width: maxPixel * aspectRatio, height: maxPixel)
  }
}
