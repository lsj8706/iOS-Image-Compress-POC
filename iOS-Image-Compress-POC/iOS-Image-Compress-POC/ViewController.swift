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
  private let compressor = ImageCompressor()
  private let resizer = ImageResizer()

  private var selectedImage: UIImage? {
    didSet {
      if let selectedImage {
        self.imageDidSelected(selectedImage)
      }
    }
  }
  private var selectedType: CompressType = .png {
    didSet {
      compressTypeChanged(type: selectedType)
    }
  }

  // MARK: - UI

  private let imageView = UIImageView().then {
    $0.backgroundColor = .systemGray5
  }

  private let compressTypeButton = UIButton(type: .system).then {
    $0.showsMenuAsPrimaryAction = true
    $0.backgroundColor = .systemGray5
    $0.setTitle("압축 방법을 선택해 주세요. (default: png)", for: .normal)
    $0.setTitleColor(.black, for: .normal)
  }

  private let qualityTextField = UITextField().then {
    $0.placeholder = "퀄리티를 입력해 주세요. (default: 1.0)"
    $0.backgroundColor = .systemGray5
    $0.keyboardType = .decimalPad
    $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 44))
    $0.leftViewMode = .always
    $0.textAlignment = .center
  }

  private let originSizeLabel = UILabel().then {
    $0.text = "원본 크기: "
    $0.enableCopyOnTouch()
  }

  private let compressedSizeLabel = UILabel().then {
    $0.text = "압축 후 크기: "
    $0.enableCopyOnTouch()
  }

  private let timeLabel = UILabel().then {
    $0.text = "소요 시간: "
    $0.enableCopyOnTouch()
  }

  private let compressButton = UIButton(type: .system).then {
    $0.setTitle("압축", for: .normal)
    $0.setTitleColor(.black, for: .normal)
    $0.backgroundColor = .orange
  }

  private let saveButton = UIButton(type: .system).then {
    $0.setTitle("저장", for: .normal)
    $0.setTitleColor(.black, for: .normal)
    $0.backgroundColor = .orange
  }

  private lazy var stackView = UIStackView(
    arrangedSubviews: [
      compressTypeButton,
      qualityTextField,
      originSizeLabel,
      compressedSizeLabel,
      timeLabel,
      compressButton,
      saveButton
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

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
  }

  private func setupUI() {
    let menuElements = compressTypes.map { compressType in
      UIAction(title: compressType.rawValue, handler: { _ in
        self.selectedType = compressType
      })
    }

    let menu = UIMenu(title: "CompressType", options: .displayInline, children: menuElements)
    compressTypeButton.menu = menu

    [compressTypeButton, qualityTextField, compressButton, saveButton].forEach {
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

    compressButton.rx.tap
      .bind { [weak self] _ in
        guard let self, let selectedImage else { return }
        var qualityStr = self.qualityTextField.text ?? "1.0"
        if qualityStr.isEmpty {
          qualityStr = "1.0"
        }
        let quality = CGFloat(Double(qualityStr)!)

        DispatchQueue.global().async { [weak self] in
          guard let self else { return }
          let (time, data) = compressor.compress(image: selectedImage, type: selectedType, quality: quality)

          DispatchQueue.main.async { [weak self] in
            if let data {
              self?.updateCompressedSizeLabel(bytes: data.count)
              self?.updateCompressedImage(data)
              self?.updateTimeLabel(time)
            }
          }
        }
      }.disposed(by: disposeBag)

    saveButton.rx.tap
      .bind { [weak self] _ in
        guard let self, let currentImage = imageView.image else { return }
        UIImageWriteToSavedPhotosAlbum(currentImage, nil, nil, nil)
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
    printPixels(image)
  }

  private func updateCompressedImage(_ data: Data) {
    print("압축 결과 반영")
    guard let newImage = UIImage(data: data) else { return }
    imageView.image = newImage
    printPixels(newImage)
  }

  private func printPixels(_ image: UIImage) {
    let heightInPoints = image.size.height
    let heightInPixels = heightInPoints * image.scale

    let widthInPoints = image.size.width
    let widthInPixels = widthInPoints * image.scale
    print(widthInPixels, heightInPixels)
  }

  private func updateOriginSizeLabel(bytes: Int) {
    let mb = CGFloat(bytes) / CGFloat(1024 * 1024)
    originSizeLabel.text = "원본 크기: \(mb) MB"
  }

  private func updateCompressedSizeLabel(bytes: Int) {
    let mb = CGFloat(bytes) / CGFloat(1024 * 1024)
    compressedSizeLabel.text = "압축 후 크기: \(mb) MB"
  }

  private func updateTimeLabel(_ timeInterval: TimeInterval) {
    timeLabel.text = "소요 시간: \(timeInterval) 초"
  }
}

extension ViewController: PHPickerViewControllerDelegate {
  func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
    picker.dismiss(animated: true)

    guard let itemProvider = results.first?.itemProvider else { return }

    if itemProvider.canLoadObject(ofClass: UIImage.self) {
      itemProvider.loadObject(ofClass: UIImage.self) { image, _ in
        DispatchQueue.main.async {
          guard let selectedImage = image as? UIImage else { return }
          let resizedImage = self.resizer.process(selectedImage)
          self.selectedImage = resizedImage
        }
      }
    }

    if itemProvider.canLoadObject(ofClass: UIImage.self) {
      itemProvider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { data, _ in
        guard let imageData = data else {
          print("데이터로 변환 실패")
          return
        }
        // imageData의 크기를 바이트 단위로 얻음
        let imageSize = imageData.count

        DispatchQueue.main.async {
          self.updateOriginSizeLabel(bytes: imageSize)
        }
      }
    }
  }
}
