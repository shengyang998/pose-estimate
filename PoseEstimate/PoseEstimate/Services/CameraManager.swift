//
//  CameraManager.swift
//  PoseEstimate
//
//  Created by Soleil Yu on 2025/11/9.
//

import AVFoundation
import Foundation

/// Delegate protocol for receiving camera frames
protocol CameraManagerDelegate: AnyObject {
    func cameraManager(_ manager: CameraManager, didOutput sampleBuffer: CMSampleBuffer)
    func cameraManager(_ manager: CameraManager, didFailWithError error: Error)
}

/// Manages camera capture session and frame delivery
class CameraManager: NSObject {
    
    // MARK: - Properties
    
    weak var delegate: CameraManagerDelegate?
    
    private let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let sessionQueue = DispatchQueue(label: "com.poseestimate.camera.session")
    private let outputQueue = DispatchQueue(label: "com.poseestimate.camera.output")
    
    private(set) var isRunning = false
    private(set) var isConfigured = false
    
    // MARK: - Public Methods
    
    /// Request camera permission
    func requestCameraPermission() async throws -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .video)
        case .denied, .restricted:
            throw PoseEstimationError.cameraPermissionDenied
        @unknown default:
            throw PoseEstimationError.cameraPermissionDenied
        }
    }
    
    /// Set up the capture session
    func setupCaptureSession() throws {
        // Avoid reconfiguring if already set up
        guard !isConfigured else {
            print("CameraManager: Already configured, skipping setup")
            return
        }
        
        sessionQueue.sync {
            captureSession.beginConfiguration()
            
            // Set session preset
            captureSession.sessionPreset = .high
            
            // Add video input
            guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                  let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
                  captureSession.canAddInput(videoInput) else {
                captureSession.commitConfiguration()
                print("CameraManager: Failed to add video input")
                delegate?.cameraManager(self, didFailWithError: PoseEstimationError.cameraConfigurationFailed)
                return
            }
            
            captureSession.addInput(videoInput)
            
            // Configure video output
            videoOutput.setSampleBufferDelegate(self, queue: outputQueue)
            videoOutput.alwaysDiscardsLateVideoFrames = true
            videoOutput.videoSettings = [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
            ]
            
            guard captureSession.canAddOutput(videoOutput) else {
                captureSession.commitConfiguration()
                print("CameraManager: Failed to add video output")
                delegate?.cameraManager(self, didFailWithError: PoseEstimationError.cameraConfigurationFailed)
                return
            }
            
            captureSession.addOutput(videoOutput)
            
            // Set video orientation
            if let connection = videoOutput.connection(with: .video) {
                if connection.isVideoOrientationSupported {
                    connection.videoOrientation = .portrait
                }
            }
            
            captureSession.commitConfiguration()
            isConfigured = true
            print("CameraManager: Configuration successful")
        }
    }
    
    /// Start the capture session
    func startCapture() {
        guard isConfigured else {
            print("CameraManager: Cannot start - not configured")
            return
        }
        
        sessionQueue.async { [weak self] in
            guard let self = self, !self.isRunning else { 
                print("CameraManager: Already running, skipping start")
                return 
            }
            print("CameraManager: Starting capture session")
            self.captureSession.startRunning()
            self.isRunning = true
        }
    }
    
    /// Stop the capture session
    func stopCapture() {
        sessionQueue.async { [weak self] in
            guard let self = self, self.isRunning else { 
                print("CameraManager: Not running, skipping stop")
                return 
            }
            print("CameraManager: Stopping capture session")
            self.captureSession.stopRunning()
            self.isRunning = false
        }
    }
    
    /// Get the capture session for preview
    func getCaptureSession() -> AVCaptureSession {
        return captureSession
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        delegate?.cameraManager(self, didOutput: sampleBuffer)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Frame was dropped - this is normal when processing can't keep up
    }
}

