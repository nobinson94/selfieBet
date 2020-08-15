//
//  ImagePickerViewModel.swift
//  SelfieBet
//
//  Created by 용태권 on 2020/08/09.
//  Copyright © 2020 Yongtae.Kwon. All rights reserved.
//

import Foundation
import Photos
import RxCocoa
import UIKit
import RxSwift

class ImagePickerViewModel: NSObject {
    
    struct Action {
        let select = PublishSubject<IndexPath>()
    }
    
    struct State {
        let imageAssets = BehaviorRelay<PHFetchResult<PHAsset>>(value:PHFetchResult())
        let selectAsset = BehaviorRelay<PHAsset?>(value: nil)
    }
    
    var action = Action()
    var state = State()
    let disposeBag = DisposeBag()
    
    let imageManager = PHCachingImageManager()
    
    private lazy var fetchOptions: PHFetchOptions = {
       let fetchOptions = PHFetchOptions()
       fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
       return fetchOptions
    }()
    
    override init() {
        super.init()
        setRx()
        state.imageAssets.accept(PHAsset.fetchAssets(with: .image, options: fetchOptions))
    }
    
    func setRx() {
    }
    
    func fetchImage() {
        
    }

}
