//
//  ImagePickerViewController.swift
//  SelfieBet
//
//  Created by 용태권 on 2020/08/09.
//  Copyright © 2020 Yongtae.Kwon. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit
import Photos

class ImagePickerViewController: UIViewController {
    
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    private let viewModel = ImagePickerViewModel()
    private let disposeBag = DisposeBag()
    
    override var prefersStatusBarHidden: Bool { return true }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        setRx()
        setTheme()
    }
    
    private func setView() {
        collectionView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        collectionView.rx
            .setDataSource(self)
            .disposed(by: disposeBag)
        
    }
    
    private func setRx() {
        confirmButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let photoViewController = self?.storyboard?.instantiateViewController(withIdentifier: "Photo") as? PhotoViewController else { return }
                
                photoViewController.modalPresentationStyle = .fullScreen
                guard let asset = self?.viewModel.state.selectAsset.value else { return }
                let manager = PHCachingImageManager.default()
                let width  = photoViewController.resultImageView?.bounds.width ?? 414
                let height = photoViewController.resultImageView?.bounds.height ?? 512
                let newSize = CGSize(width: width * UIScreen.main.scale, height: height * UIScreen.main.scale)
                
                manager.requestImage(for: asset,
                                     targetSize: newSize,
                                     contentMode: .aspectFill,
                                     options: ImageCollectionViewCell.phImageOptions) { [weak self] (result, _) in
                                        photoViewController.resultImage = result
                                        self?.modalPresentationStyle = .fullScreen
                                        self?.present(photoViewController, animated: true)
                }
            }).disposed(by: disposeBag)
        
        viewModel.state.selectAsset.asObservable()
            .distinctUntilChanged()
            .observeOn(MainScheduler())
            .subscribe(onNext: { [weak self] asset in
                self?.confirmButton.isEnabled = asset != nil
                if asset != nil {
                    self?.confirmButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
                }
            }).disposed(by: disposeBag)
    }
    
    private func setTheme() {
        
    }
}

extension ImagePickerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell else {
            return
        }
        
        viewModel.state.selectAsset.accept(cell.asset)
        cell.isSelected = true
        cell.updateCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell else {
            return
        }
        cell.isSelected = false
        cell.updateCell()
    }
    
}


extension ImagePickerViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.state.imageAssets.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as? ImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.asset = viewModel.state.imageAssets.value.object(at: indexPath.item)
        cell.isSelected = viewModel.state.selectAsset.value?.localIdentifier == cell.asset?.localIdentifier
        cell.updateCell()
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
}

extension ImagePickerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }
        var cellCountInRow = 3
        
        
        if UIDevice.current.orientation.isLandscape {
            cellCountInRow = 6
        }
        
        let size = (collectionView.bounds.width - (flowLayout.sectionInset.left + flowLayout.sectionInset.right) - (flowLayout.minimumLineSpacing * CGFloat(cellCountInRow - 1))) / CGFloat(cellCountInRow)
        
        return CGSize(width: size, height: size)
    }
}

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    var assetRequestID: PHImageRequestID?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(imageLiteralResourceName: "imagePickerPlaceHolder")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        guard let id = assetRequestID else { return }
        PHCachingImageManager.default().cancelImageRequest(id)
        assetRequestID = nil
        imageView.image = UIImage(imageLiteralResourceName: "imagePickerPlaceHolder")
        asset = nil
        isSelected = false
    }
    
    static var phImageOptions: PHImageRequestOptions {
        let options = PHImageRequestOptions()
        options.version = .original
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .fast
        options.isSynchronous = false
        options.isNetworkAccessAllowed = true
        
        return options
    }
    
    var asset: PHAsset? {
        didSet {
            updateAsset()
        }
    }
    
    func updateAsset() {
        guard let asset = asset else { return }
        let manager = PHCachingImageManager.default()
        let newSize = CGSize(width: imageView.bounds.width * UIScreen.main.scale, height: imageView.bounds.height * UIScreen.main.scale)

        assetRequestID = manager.requestImage(for: asset,
                                              targetSize: newSize,
                                              contentMode: .aspectFill,
                                              options: ImageCollectionViewCell.phImageOptions,
                                              resultHandler: { [weak self] (result, _) in
                                                guard let self = self,
                                                    let currentAsset = self.asset, currentAsset.isEqual(asset) else { return }
                                                self.imageView.image = result
        })
        
    }
    
    func updateCell() {
        if isSelected {
            self.layer.opacity = 0.5
        } else {
            self.layer.opacity = 1
        }
    }
    
}

