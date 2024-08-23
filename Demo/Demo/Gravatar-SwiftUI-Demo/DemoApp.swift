//
//  DemoApp.swift
//  Demo
//
//  Created by Andrew Montgomery on 1/19/24.
//

import SwiftUI
import Gravatar

@main
struct DemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    setupSecrets()
                }
        }
    }

    func setupSecrets() {
        Task {
            await Configuration.shared.configure(
                with: Secrets.apiKey,
                oauthSecrets: .init(
                    clientID: Secrets.clientID,
                    clientSecret: Secrets.clientSecret,
                    redirectURI: Secrets.redirectURI
                )
            )
        }
    }
}
