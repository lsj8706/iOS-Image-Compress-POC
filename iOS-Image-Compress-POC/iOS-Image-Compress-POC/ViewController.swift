//
//  ViewController.swift
//  iOS-Image-Compress-POC
//
//  Created by Aiden.lee on 2024/04/10.
//

import UIKit

import RxSwift
import SnapKit
import Then

final class ViewController: UIViewController {

  // MARK: - Properties

  private let compressTypes = CompressType.allCases

  // MARK: - UI

  private let imageView = UIImageView().then {
    $0.backgroundColor = .orange
  }

  private let compressTypeButton = UIButton(type: .system).then {
    $0.showsMenuAsPrimaryAction = true
    $0.backgroundColor = .systemGray5
    $0.setTitleColor(.black, for: .normal)
    $0.setTitle("압축 방법 선택", for: .normal)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    setupLayout()
  }

  private func setupUI() {
    let menuElements = compressTypes.map { compressType in
      UIAction(title: compressType.rawValue, handler: { _ in
        self.compressTypeChanged(type: compressType)
      })
    }

    let menu = UIMenu(title: "CompressType", options: .displayInline, children: menuElements)
    compressTypeButton.menu = menu
  }

  private func setupLayout() {
    [imageView, compressTypeButton].forEach { subView in
      subView.translatesAutoresizingMaskIntoConstraints = false
      view.addSubview(subView)
    }

    imageView.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
      make.leading.trailing.equalToSuperview().inset(20)
      make.height.equalTo(imageView.snp.width)
    }

    compressTypeButton.snp.makeConstraints { make in
      make.top.equalTo(imageView.snp.bottom).offset(20)
      make.leading.trailing.equalToSuperview().inset(20)
      make.height.equalTo(44)
    }
  }
}

extension ViewController {
  private func compressTypeChanged(type: CompressType) {
    compressTypeButton.setTitle(type.rawValue, for: .normal)
    print(type.rawValue)
  }
}

