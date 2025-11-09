//
//  VideoPlayerView.swift
//  PoseEstimate
//
//  Created by Soleil Yu on 2025/11/9.
//

import SwiftUI
import AVKit

/// SwiftUI wrapper for AVPlayer
struct VideoPlayerView: UIViewControllerRepresentable {
    let player: AVPlayer
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = true
        controller.videoGravity = .resizeAspect
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // No updates needed
    }
}

