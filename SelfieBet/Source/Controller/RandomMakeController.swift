//
//  RandomMakeController.swift
//  SelfieBet
//
//  Created by 용태권 on 2020/08/05.
//  Copyright © 2020 Yongtae.Kwon. All rights reserved.
//

import Foundation
import RxSwift

enum RandomGenerateError : Error {
    case totalNumberNotExist
    case targetNumberTooLarge
}
class RandomMakeController: NSObject {
    
    let shared = RandomMakeController()

    var targetNumber: Int = 1 // 이부분은 userDefault를 활용해보면 좋을 것 같다.
    var totalNumber: Int?

    private override init() {
        super.init()
    }
    
    func losers() throws -> [Int] {
        guard let total = self.totalNumber else {
            throw RandomGenerateError.totalNumberNotExist
        }
        guard targetNumber < total else {
            throw RandomGenerateError.targetNumberTooLarge
        }
        let sequence = 0 ..< total
        let shuffledSequence = sequence.shuffled()
        return Array(shuffledSequence[0...targetNumber])
    }
    
}
