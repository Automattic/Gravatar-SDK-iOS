//
//  Result+Gravatar.swift
//
//
//  Created by Pinar Olguc on 26.01.2024.
//

import Foundation

extension Result<GravatarImageDownloadResult, ImageFetchingError> {
    func convert() -> Result<GravatarImageDownloadResult, ImageFetchingComponentError> {
        switch self {
        case .success(let value):
            .success(value)
        case .failure(let error):
            .failure(error.convert())
        }
    }
}
