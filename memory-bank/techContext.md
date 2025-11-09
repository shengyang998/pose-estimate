# Technical Context

## Platform & Language
- **Platform**: iOS (iPhone and iPad)
- **Minimum iOS Version**: iOS 15.0+
- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI
- **IDE**: Xcode 15+

## Core Technologies

### Machine Learning & Computer Vision
- **Vision Framework**: Apple's framework for computer vision tasks
  - VNDetectHumanBodyPoseRequest for pose detection
  - VNRecognizedPointsObservation for keypoint data
- **CoreML**: For custom or additional ML models if needed
- **MLModel**: Pre-trained pose estimation models

### Media Handling
- **AVFoundation**: Camera capture and video playback
  - AVCaptureSession for camera input
  - AVCaptureVideoDataOutput for frame processing
  - AVPlayer for video playback
  - AVAsset for video file handling
- **PhotosUI**: Video selection from photo library
- **CoreImage**: Optional image processing

### Rendering & Graphics
- **SwiftUI**: Primary UI framework
- **Core Graphics**: Drawing skeleton overlays
- **CALayer**: Custom rendering layers if needed
- **Metal**: Potential for GPU-accelerated rendering

## Key Dependencies
- No external package dependencies (currently using native frameworks)
- All required frameworks are part of iOS SDK

## Development Setup

### Build Configuration
- Development Target: iOS 15.0+
- Swift Language Version: 5.9+
- Build System: Xcode Build System

### Testing Setup
Unit testing command:
```bash
xcodebuild build-for-testing -scheme PoseEstimate -destination "platform=iOS Simulator,name=iPhone 16 Pro" -configuration Debug
```

### Required Permissions
- **Camera Access**: NSCameraUsageDescription in Info.plist
- **Photo Library Access**: NSPhotoLibraryUsageDescription in Info.plist

## Technical Constraints

### Performance Constraints
- Real-time processing at 30+ FPS
- Limited CPU/GPU budget for mobile devices
- Battery consumption considerations
- Memory constraints on older devices

### ML Model Constraints
- Model size must be reasonable for app bundle
- Inference time must support real-time processing
- Model must work offline (no cloud dependency)
- Accuracy vs. performance trade-offs

### Platform Constraints
- iOS sandbox restrictions
- App Store guidelines compliance
- Privacy requirements for camera/photo access
- Background execution limitations

## Architecture Decisions

### Chosen Patterns
- **MVVM**: Model-View-ViewModel for SwiftUI
- **Async/Await**: Modern Swift concurrency
- **Combine**: Reactive data flow where needed
- **Protocol-Oriented**: Swift best practices

### Coding Standards
- Follow SOLID principles
- Use Assert statements for development/debugging
- Proper error handling throughout
- Performance-optimized implementations
- Comments only for complex logic
- Preserve existing code comments
- Respect prettier preferences

## Future Technical Considerations
- Support for custom ML models
- GPU acceleration for rendering
- Background processing capabilities
- Export functionality (video/data)
- Multiple camera support (front/back)

