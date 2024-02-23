//
//  SimpleCounter.swift
//
//
//  Created by Pinar Olguc on 18.01.2024.
//

import Foundation

enum SimpleCounter {
    private(set) static var current: UInt = 0
    static func next() -> UInt {
        current += 1
        return current
    }
}
