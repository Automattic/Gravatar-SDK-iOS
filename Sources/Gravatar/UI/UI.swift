//
//  File.swift
//  
//
//  Created by Pinar Olguc on 26.03.2024.
//

import Foundation
import UIKit

@MainActor
struct UI {
    
    static let scaleFactor: CGFloat = {
        return UIScreen.main.scale
    }()
}
