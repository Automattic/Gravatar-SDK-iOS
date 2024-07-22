//
//  ContentView.swift
//  Demo
//
//  Created by Andrew Montgomery on 1/19/24.
//

import SwiftUI

struct ContentView: View {
    @State var path: [String] = []
    
    enum Page: Int, CaseIterable, Identifiable {
        case avatarView = 0
        
        var id: Int {
            self.rawValue
        }
        
        var title: String {
            switch self {
            case .avatarView:
                "Avatar View"
            }
        }
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                ForEach(Page.allCases) { page in
                    Button(page.title) {
                        path.append(page.title)
                    }
                }
            }
            .navigationDestination(for: String.self) { value in
                VStack(spacing: 20) {
                    switch value {
                    case Page.avatarView.title:
                        DemoAvatarView()
                    default:
                        Text("-")
                    }
                }
            }
        }
    }
    
}

#Preview {
    ContentView()
}
