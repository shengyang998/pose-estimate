//
//  MainTabView.swift
//  PoseEstimate
//
//  Created by Soleil Yu on 2025/11/9.
//

import SwiftUI

/// Main tab view for switching between Camera and Video modes
struct MainTabView: View {
    var body: some View {
        TabView {
            CameraView()
                .tabItem {
                    Label("Camera", systemImage: "camera.fill")
                }
            
            VideoView()
                .tabItem {
                    Label("Video", systemImage: "video.fill")
                }
        }
    }
}

#Preview {
    MainTabView()
}

