//
//  ContentView.swift
//  PoseEstimate
//
//  Created by Soleil Yu on 2025/11/9.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appViewModel = AppViewModel()
    
    var body: some View {
        Group {
            if appViewModel.isInitialized {
                MainTabView()
                    .transition(.opacity)
            } else {
                // Splash screen with loading
                ZStack {
                    // Background
                    Color.black
                        .ignoresSafeArea()
                    
                    VStack(spacing: 30) {
                        // App logo or icon
                        Image(systemName: "figure.run")
                            .font(.system(size: 80))
                            .foregroundColor(.white)
                        
                        Text("Pose Estimate")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        // Loading indicator
                        VStack(spacing: 16) {
                            ProgressView(value: appViewModel.initializationProgress)
                                .progressViewStyle(.linear)
                                .tint(.green)
                                .frame(width: 250)
                            
                            Text(appViewModel.initializationMessage)
                                .foregroundColor(.white.opacity(0.8))
                                .font(.subheadline)
                        }
                        .padding(.top, 40)
                    }
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: appViewModel.isInitialized)
        .task {
            await appViewModel.initialize()
        }
    }
}

#Preview {
    ContentView()
}
