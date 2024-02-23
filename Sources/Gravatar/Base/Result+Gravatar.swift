//
//  Result+Gravatar.swift
//
//
//  Created by Pinar Olguc on 26.01.2024.
//

import Foundation

extension Result<GravatarImageDownloadResult, GravatarImageDownloadError> {
    func convert() -> Result<GravatarImageDownloadResult, GravatarImageSetError> {
        switch self {
        case .success(let value):
            .success(value)
        case .failure(let error):
            .failure(error.convert())
        }
    }
}
