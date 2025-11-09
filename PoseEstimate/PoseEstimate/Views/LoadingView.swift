//
//  LoadingView.swift
//  PoseEstimate
//
//  Created by Soleil Yu on 2025/11/9.
//

import SwiftUI

/// Reusable loading overlay view
struct LoadingView: View {
    let message: String
    let progress: Double?
    
    init(message: String = "加载中...", progress: Double? = nil) {
        self.message = message
        self.progress = progress
    }
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            // Loading card
            VStack(spacing: 20) {
                // Spinner or progress
                if let progress = progress {
                    // Progress view with percentage
                    VStack(spacing: 12) {
                        ProgressView(value: progress)
                            .progressViewStyle(.linear)
                            .tint(.green)
                            .frame(width: 200)
                        
                        Text("\(Int(progress * 100))%")
                            .foregroundColor(.white)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .monospacedDigit()
                    }
                } else {
                    // Indeterminate spinner
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(1.5)
                        .tint(.white)
                }
                
                // Message
                Text(message)
                    .foregroundColor(.white)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.85))
            )
            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
        }
    }
}

/// ViewModifier for showing loading overlay
struct LoadingModifier: ViewModifier {
    let isLoading: Bool
    let message: String
    let progress: Double?
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isLoading {
                LoadingView(message: message, progress: progress)
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isLoading)
    }
}

/// View extension for easy loading overlay
extension View {
    /// Show loading overlay
    /// - Parameters:
    ///   - isLoading: Whether to show the loading view
    ///   - message: Loading message to display
    ///   - progress: Optional progress value (0-1). If nil, shows indeterminate spinner
    func loading(
        _ isLoading: Bool,
        message: String = "加载中...",
        progress: Double? = nil
    ) -> some View {
        modifier(LoadingModifier(
            isLoading: isLoading,
            message: message,
            progress: progress
        ))
    }
}

#Preview("Indeterminate") {
    VStack {
        Text("Content behind loading")
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.gray.opacity(0.2))
    .loading(true, message: "正在加载...")
}

#Preview("With Progress") {
    VStack {
        Text("Content behind loading")
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.gray.opacity(0.2))
    .loading(true, message: "处理视频中...", progress: 0.65)
}

