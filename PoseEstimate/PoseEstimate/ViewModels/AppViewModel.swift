//
//  AppViewModel.swift
//  PoseEstimate
//
//  Created by Soleil Yu on 2025/11/9.
//

import Foundation
import AVFoundation
import Vision
import Combine

/// Manages app initialization and startup state
@MainActor
class AppViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var isInitialized = false
    @Published var initializationProgress: Double = 0.0
    @Published var initializationMessage = "正在启动..."
    
    // MARK: - Initialization
    
    /// Initialize app components
    func initialize() async {
        // Step 1: Check camera authorization status
        updateProgress(0.3, message: "检查相机权限...")
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        
        let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        print("AppViewModel: Camera authorization status - \(cameraStatus.rawValue)")
        
        // Step 2: Verify Vision framework availability
        updateProgress(0.6, message: "初始化姿态识别模块...")
        try? await Task.sleep(nanoseconds: 300_000_000)
        
        // Test Vision framework
        let visionRequest = VNDetectHumanBodyPoseRequest()
        print("AppViewModel: Vision framework initialized - \(visionRequest.revision)")
        
        // Step 3: Prepare resources
        updateProgress(0.9, message: "准备资源...")
        try? await Task.sleep(nanoseconds: 300_000_000)
        
        // Step 4: Complete
        updateProgress(1.0, message: "启动完成")
        try? await Task.sleep(nanoseconds: 200_000_000)
        
        isInitialized = true
        print("AppViewModel: Initialization complete")
    }
    
    // MARK: - Private Methods
    
    private func updateProgress(_ progress: Double, message: String) {
        initializationProgress = progress
        initializationMessage = message
    }
}

