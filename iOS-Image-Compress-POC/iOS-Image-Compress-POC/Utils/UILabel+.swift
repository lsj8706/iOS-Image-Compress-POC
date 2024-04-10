//
//  UILabel+.swift
//  iOS-Image-Compress-POC
//
//  Created by Aiden.lee on 2024/04/10.
//

import UIKit

extension UILabel {
  func enableCopyOnTouch() {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped(sender:)))

    self.isUserInteractionEnabled = true
    self.addGestureRecognizer(tapGesture)
  }

  @objc
  private func labelTapped(sender: UITapGestureRecognizer) {
    guard let _ = sender.view as? UILabel, let text else {
      return
    }

    let components = text.components(separatedBy: " ")
    let num = components[components.count-2]
    
    UIPasteboard.general.string = num
  }
}
