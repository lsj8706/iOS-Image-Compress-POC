//
//  ViewController.swift
//  iOS-Image-Compress-POC
//
//  Created by Aiden.lee on 2024/04/10.
//

import UIKit
import PhotosUI

import RxSwift
import RxCocoa
import RxGesture
import SnapKit
import Then

final class ViewController: UIViewController {

  // MARK: - Properties

  private let compressTypes = CompressType.allCases
  private let disposeBag = DisposeBag()

  // MARK: - UI

  private let imageView = UIImageView().then {
    $0.backgroundColor = .systemGray5
  }

  private let compressTypeButton = UIButton(type: .system).then {
    $0.showsMenuAsPrimaryAction = true
    $0.backgroundColor = .systemGray5
    $0.setTitle("압축 방법 선택", for: .normal)
    $0.setTitleColor(.black, for: .normal)
  }

  private let qualityTextField = UITextField().then {
    $0.placeholder = "퀄리티를 입력해 주세요."
    $0.backgroundColor = .systemGray5
    $0.keyboardType = .decimalPad
    $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 44))
    $0.leftViewMode = .always
    $0.textAlignment = .center
  }

  private let originSizeLabel = UILabel().then {
    $0.text = "원본 크기: "
  }

  private let compressedSizeLabel = UILabel().then {
    $0.text = "압축 후 크기: "
  }

  private let compressButton = UIButton(type: .system).then {
    $0.setTitle("압축", for: .normal)
    $0.setTitleColor(.black, for: .normal)
    $0.backgroundColor = .orange
  }

  private lazy var stackView = UIStackView(
    arrangedSubviews: [
      compressTypeButton,
      qualityTextField,
      originSizeLabel,
      compressedSizeLabel,
      compressButton
    ]
  ).then {
    $0.axis = .vertical
    $0.spacing = 10
    $0.distribution = .fillEqually
  }

  // MARK: - Life Cycle

  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    setupLayout()
    bind()
  }

  private func setupUI() {
    let menuElements = compressTypes.map { compressType in
      UIAction(title: compressType.rawValue, handler: { _ in
        self.compressTypeChanged(type: compressType)
      })
    }

    let menu = UIMenu(title: "CompressType", options: .displayInline, children: menuElements)
    compressTypeButton.menu = menu

    [compressTypeButton, qualityTextField, compressButton].forEach {
      $0.layer.cornerRadius = 10
    }
  }

  private func setupLayout() {
    [
      imageView,
      stackView
    ].forEach { subView in
      subView.translatesAutoresizingMaskIntoConstraints = false
      view.addSubview(
        subView
      )
    }

    imageView.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
      make.leading.trailing.equalToSuperview().inset(20)
      make.height.equalTo(imageView.snp.width)
    }

    stackView.snp.makeConstraints { make in
      make.top.equalTo(imageView.snp.bottom).offset(20)
      make.leading.trailing.equalToSuperview().inset(20)
    }

    compressTypeButton.snp.makeConstraints { make in
      make.height.equalTo(44)
    }
  }

  private func bind() {
    imageView.rx.tapGesture()
      .when(.recognized)
      .bind { [weak self] _ in
        self?.presentImagePicker()
      }.disposed(by: disposeBag)
  }
}

extension ViewController {
  private func compressTypeChanged(type: CompressType) {
    compressTypeButton.setTitle(type.rawValue, for: .normal)
    print(type.rawValue)
  }

  private func presentImagePicker() {
    var config = PHPickerConfiguration()
    config.selectionLimit = 1
    config.filter = .images

    let picker = PHPickerViewController(configuration: config)
    picker.delegate = self
    present(picker, animated: true)
  }

  private func imageDidSelected(_ image: UIImage) {
    imageView.image = image
  }
}

extension ViewController: PHPickerViewControllerDelegate {
  func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
    picker.dismiss(animated: true)

    let itemProvider = results.first?.itemProvider
    if let itemProvider = itemProvider,
       itemProvider.canLoadObject(ofClass: UIImage.self) {
      itemProvider.loadObject(ofClass: UIImage.self) { image, error in
        DispatchQueue.main.async {
          guard let selectedImage = image as? UIImage else { return }
          self.imageDidSelected(selectedImage)
        }
      }
    }
  }
}
