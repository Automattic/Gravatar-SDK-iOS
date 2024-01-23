//
//  GravatarImageProcessor.swift
//
//
//  Created by Pinar Olguc on 18.01.2024.
//

import Foundation
import UIKit


public protocol GravatarImageProcessor {
    func process(_ data: Data, options: GravatarDownloadOptions) -> UIImage?
}
