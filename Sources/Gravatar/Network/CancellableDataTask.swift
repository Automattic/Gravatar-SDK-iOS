//
//  File.swift
//  
//
//  Created by Pinar Olguc on 19.01.2024.
//

import Foundation

public protocol CancellableDataTask {
    func cancel()
    var taskIdentifier: Int { get }
}

extension URLSessionTask: CancellableDataTask { }
