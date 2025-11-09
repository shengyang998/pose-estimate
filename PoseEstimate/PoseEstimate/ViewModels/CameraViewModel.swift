//
//  CameraViewModel.swift
//  PoseEstimate
//
//  Created by Soleil Yu on 2025/11/9.
//

import Foundation
import AVFoundation
import Combine

/// ViewModel for camera-based pose estimation
@MainActor
class CameraViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var detectedPose: PoseModel?
    @Published var isProcessing = false
    @Published var error: PoseEstimationError?
    @Published var permissionGranted = false
    
    // MARK: - Private Properties
    
    private let cameraManager: CameraManager
    private let poseEstimator: PoseEstimator
    private var processingTask: Task<Void, Never>?
    
    // MARK: - Initialization
    
    init() {
        self.cameraManager = CameraManager()
        self.poseEstimator = PoseEstimator()
        self.cameraManager.delegate = self
    }
    
    // MARK: - Public Methods
    
    /// Request camera permission and set up camera
    func requestPermission() async {
        do {
            let granted = try await cameraManager.requestCameraPermission()
            permissionGranted = granted
            
            if granted {
                try cameraManager.setupCaptureSession()
            }
        } catch let error as PoseEstimationError {
            self.error = error
        } catch {
            self.error = .cameraPermissionDenied
        }
    }
    
    /// Start camera capture
    func startCapture() {
        guard permissionGranted else { return }
        cameraManager.startCapture()
    }
    
    /// Stop camera capture
    func stopCapture() {
        cameraManager.stopCapture()
        processingTask?.cancel()
    }
    
    /// Get capture session for preview layer
    func getCaptureSession() -> AVCaptureSession {
        return cameraManager.getCaptureSession()
    }
    
    // MARK: - Private Methods
    
    private func processFrame(_ sampleBuffer: CMSampleBuffer) {
        // Cancel any existing processing task
        processingTask?.cancel()
        
        processingTask = Task { [weak self] in
            guard let self = self else { return }
            
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                return
            }
            
            do {
                let pose = try await self.poseEstimator.detectPose(in: pixelBuffer)
                
                // Update UI on main thread
                await MainActor.run {
                    self.detectedPose = pose
                }
            } catch {
                // Silently handle processing errors - they're expected when no pose is visible
            }
        }
    }
}

// MARK: - CameraManagerDelegate

extension CameraViewModel: CameraManagerDelegate {
    nonisolated func cameraManager(_ manager: CameraManager, didOutput sampleBuffer: CMSampleBuffer) {
        Task { @MainActor in
            guard !isProcessing else { return }
            isProcessing = true
            processFrame(sampleBuffer)
            isProcessing = false
        }
    }
    
    nonisolated func cameraManager(_ manager: CameraManager, didFailWithError error: Error) {
        Task { @MainActor in
            if let poseError = error as? PoseEstimationError {
                self.error = poseError
            } else {
                self.error = .cameraConfigurationFailed
            }
        }
    }
}

