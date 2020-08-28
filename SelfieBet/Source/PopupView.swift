//
//  PopupView.swift
//  SelfieBet
//
//  Created by USER on 2020/08/26.
//  Copyright © 2020 Yongtae.Kwon. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PopupView: UIView {
    
    let targetNumber = BehaviorRelay<Int>(value: 0)
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var targetNumberLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    
    override func awakeFromNib() {
        setRx()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setRx() {
        targetNumber.asObservable()
            .map { number -> String? in
                return "\(number)명"
            }.bind(to: targetNumberLabel.rx.text)
            .disposed(by: disposeBag)
        
        plusButton.rx.tap
            .map { self.targetNumber.value + 1 }
            .subscribe(onNext: { [weak self] number in
                guard number >= 0 else { return }
                self?.targetNumber.accept(number)
            }).disposed(by: disposeBag)
        
        minusButton.rx.tap
            .map { self.targetNumber.value - 1 }
            .subscribe(onNext: { [weak self] number in
                guard number >= 0 else { return }
                self?.targetNumber.accept(number)
            }).disposed(by: disposeBag)

    }
    
    func loadView() -> UIView {
        let bundleName = Bundle(for: type(of: self))
        let nibName = String(describing: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundleName)
        guard let view = nib.instantiate(withOwner: nil, options: nil).first as? UIView else { return UIView() }
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor(named: "MainThemeColor")?.cgColor
        view.layer.cornerRadius = 5

        return view
    }
    
}
