//
//  File.swift
//  
//
//  Created by Pinar Olguc on 18.01.2024.
//

import Foundation

enum TaskCounter {
    static private(set) var current: UInt = 0
    static func next() -> UInt {
        current += 1
        return current
    }
}
