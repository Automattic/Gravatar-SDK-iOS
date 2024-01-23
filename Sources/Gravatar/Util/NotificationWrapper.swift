//
//  NotificationWrapper.swift
//
//
//  Created by Pinar Olguc on 18.01.2024.
//

import Foundation

class NotificationWrapper {
    let observer: NSObjectProtocol

    init(observer: NSObjectProtocol) {
        self.observer = observer
    }

    deinit {
        NotificationCenter.default.removeObserver(observer)
    }
}
