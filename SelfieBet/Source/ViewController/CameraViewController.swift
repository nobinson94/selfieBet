//
//  CameraViewController.swift
//  SelfieBet
//
//  Created by 용태권 on 2020/07/07.
//  Copyright © 2020 Yongtae.Kwon. All rights reserved.
//

import AVFoundation
import Photos
import RxSwift
import RxCocoa
import UIKit
import Vision

class CameraViewController: UIViewController {
    let cameraController = CameraController()
    let videoDataOutput = AVCaptureVideoDataOutput()
    private var drawings: [CAShapeLayer] = []
    
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var captureImageView: UIImageView!
    @IBOutlet weak var toggleCameraButton: UIButton!
    @IBOutlet weak var recognizedTargetNumber: UILabel!
    @IBOutlet weak var targetMessageButton: UIButton!
    
    
//    @IBOutlet fileprivate var toggleFlashButton: UIButton!
 
    override var prefersStatusBarHidden: Bool { return true }
    
    struct Action {
        let capturePhoto = PublishSubject<Void>()
        let savePhoto = PublishSubject<Void>()
        let toggleCameraPosition = PublishSubject<Void>()
        let pickPhoto = PublishSubject<Void>()
    }
    
    struct State {
        let detectedFaceNumber = BehaviorRelay<Int>(value: 0)
    }
    
    let action = Action()
    let state = State()
    let disposeBag = DisposeBag()
    
    var tabBarVC: TabBarController? = nil
}
 
extension CameraViewController {
    
    override func viewDidLoad() {
//        let navigationController = UINavigationController()
//        navigationController.setViewControllers([self], animated: false)
        self.tabBarVC?.setNeedsStatusBarAppearanceUpdate()
        self.cameraControllerSetup()
        self.setRx()
        setView()
    }
    
    func setRx() {
        action.capturePhoto
            .subscribe(onNext: { [weak self] _ in
                self?.cameraController.captureImage { [weak self] (image, error) in
                    guard let image = image else {
                        return
                    }
                    DispatchQueue.main.async {
                        guard let photoViewController = self?.storyboard?.instantiateViewController(withIdentifier: "Photo") as? PhotoViewController else { return }
                        photoViewController.resultImage = image
                        self?.navigationController?.pushViewController(photoViewController, animated: true)
                    }
                    ///// todo : Save Option 고려하기
//                    self?.savePhoto(image: image) { [weak self] (isSaved, _) in
//                        if isSaved {
//                            DispatchQueue.main.async {
//                                guard let photoViewController = self?.storyboard?.instantiateViewController(identifier: "Photo") as? PhotoViewController else { return }
//                                photoViewController.resultImage = image
//                                self?.navigationController?.pushViewController(photoViewController, animated: true)
//                            }
//                        }
//                    }
                }
            })
            .disposed(by: disposeBag)
        
        action.toggleCameraPosition
            .subscribe(onNext: { [weak self] _ in
                try? self?.cameraController.switchCameraPosition()
            })
            .disposed(by: disposeBag)
        
        captureButton.rx.tap
            .bind(to: self.action.capturePhoto)
            .disposed(by: disposeBag)
        
        toggleCameraButton.rx.tap
            .bind(to: self.action.toggleCameraPosition)
            .disposed(by: disposeBag)
        
        state.detectedFaceNumber.asObservable()
            .distinctUntilChanged()
            .observeOn(MainScheduler())
            .subscribe(onNext: { [weak self] number in
                if number == 0 {
                    self?.recognizedTargetNumber.text = "인식된 사람이 없어서 내기를 진행할 수 없습니다"
                } else {
                    self?.recognizedTargetNumber.text = "내기에 참s가하는 사람은 \(number)명 입니다!"
                }
            }).disposed(by: disposeBag)
    }
    
    func setView() {
        self.toggleCameraButton.setImage(UIImage(imageLiteralResourceName: "cameraSwitchIcon").maskWithColor(color: .white), for: .normal)
        self.captureButton.setImage(UIImage(imageLiteralResourceName: "cameraApertureIcon").maskWithColor(color: .white), for: .normal)
    }
    
    func cameraControllerSetup() {
        cameraController.prepare {(error) in
            if let error = error {
                print(error)
            }
            guard let capturePreviewView = self.captureImageView else { return }
            self.cameraController.videoCaptureCompletionBlock = { buffer, error in
                guard let buffer = buffer else { return }
                self.detectFace(in: buffer)
            }
            try? self.cameraController.displayPreview(on: capturePreviewView)

        }
    }
    
    func savePhoto(image: UIImage, completion: ((Bool, Error?) -> ())? = nil) {
        PHPhotoLibrary.shared().performChanges( {
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }, completionHandler: completion)
    }
    
}

extension CameraViewController {
    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        guard let capturePreviewView = self.capturePreviewView else { return }
//        cameraController.updatePreview(on: capturePreviewView)
    }
}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {

    func detectFace(in image: CVPixelBuffer) {
        let faceDetectionRequest = VNDetectFaceRectanglesRequest(completionHandler: { (request: VNRequest, error: Error?) in
            DispatchQueue.main.async {
                if let results = request.results as? [VNFaceObservation] {
                    self.handleFaceDetectionResults(results)
                } else {
                    self.state.detectedFaceNumber.accept(0)
                    self.clearDrawings()
                }
            }
        })
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: image, orientation: .upMirrored, options: [:])
        try? imageRequestHandler.perform([faceDetectionRequest])
    }
    
    private func handleFaceDetectionResults(_ observedFaces: [VNFaceObservation]) {
        self.state.detectedFaceNumber.accept(observedFaces.count)
        self.clearDrawings()
        let facesBoundingBoxes: [CAShapeLayer] = observedFaces.map({ (observedFace: VNFaceObservation) -> CAShapeLayer in
            let faceBoundingBoxOnScreen = cameraController.previewLayer.layerRectConverted(fromMetadataOutputRect: observedFace.boundingBox)
            let faceBoundingBoxPath = CGPath(rect: faceBoundingBoxOnScreen, transform: nil)
            let faceBoundingBoxShape = CAShapeLayer()
            faceBoundingBoxShape.path = faceBoundingBoxPath
            faceBoundingBoxShape.fillColor = UIColor.clear.cgColor
            faceBoundingBoxShape.strokeColor = UIColor(named: "MainThemeColor")?.cgColor
            return faceBoundingBoxShape
        })
        DispatchQueue.main.async {
            guard let capturePreviewView = self.captureImageView else { return }
            facesBoundingBoxes.forEach({ faceBoundingBox in capturePreviewView.layer.addSublayer(faceBoundingBox) })
            self.drawings = facesBoundingBoxes
        }
        
    }
    
    private func clearDrawings() {
        self.drawings.forEach({ drawing in drawing.removeFromSuperlayer() })
    }
}

// camera용 뷰컨트롤러를 따로 만들어주는게 낫겟다.. Container랑
