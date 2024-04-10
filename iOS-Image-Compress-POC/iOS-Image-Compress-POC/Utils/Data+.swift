//
//  Data+.swift
//  iOS-Image-Compress-POC
//
//  Created by Aiden.lee on 2024/04/10.
//

import Foundation

extension Data {
  public func mimeType() -> (mimeType: String, ext: String) {
    let c = [UInt8](self)
    switch c[0] {
    case 0xFF:
      return ("image/jpeg", "jpg")
    case 0x89:
      return ("image/png", "png")
    case 0x47:
      return ("image/gif", "gif")
    case 0x49, 0x4D:
      return ("image/tiff", "tiff")
    case 0x25:
      return ("application/pdf", "pdf")
    case 0xD0:
      return ("application/vnd", "vnd")
    case 0x46:
      return ("text/plain", "")
    default:
      return ("application/octet-stream", "")
    }
  }

  var isWebP: Bool {
    // WebP 이미지는 'RIFF'로 시작하고, 그 다음에는 파일 길이(4바이트)가 오며,
    // 그 후에 'WEBP'라는 문자열이 나타납니다.
    let riffHeader = [UInt8]("RIFF".utf8)
    let webpHeader = [UInt8]("WEBP".utf8)

    var buffer = [UInt8](repeating: 0, count: 12)
    self.copyBytes(to: &buffer, count: 12)

    // 'RIFF'와 'WEBP' 문자열을 확인합니다.
    let hasRIFFHeader = riffHeader.enumerated().allSatisfy { offset, byte in buffer[offset] == byte }
    let hasWEBPHeader = webpHeader.enumerated().allSatisfy { offset, byte in buffer[offset + 8] == byte }

    return hasRIFFHeader && hasWEBPHeader
  }
}
