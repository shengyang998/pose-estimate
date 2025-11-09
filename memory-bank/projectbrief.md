# Project Brief: iOS Pose Estimation App

## Project Overview
An iOS application for human pose estimation that provides real-time skeleton visualization and video analysis capabilities using pre-trained neural network models.

## Core Requirements

### Feature 1: Real-time Camera Pose Estimation
- Capture live video feed from device camera
- Process frames in real-time using pose estimation model
- Overlay skeleton visualization on camera feed
- Display human body keypoints and connections
- Maintain smooth performance (target 30+ FPS)

### Feature 2: Video Pose Estimation
- Allow users to select and open video files from device
- Process video frames with pose estimation
- Overlay skeleton visualization on video playback
- Support standard video formats (MP4, MOV, etc.)
- Provide playback controls (play, pause, seek)

## Technical Requirements

### Machine Learning
- Integrate pre-trained neural network models for pose estimation
- Use Apple's Vision framework and/or CoreML
- Support detection of key body points (head, shoulders, elbows, wrists, hips, knees, ankles, etc.)
- Handle single or multiple person detection

### Performance
- Real-time processing with minimal latency
- Efficient memory usage
- Smooth UI experience
- Battery-conscious implementation

### Platform
- iOS platform (iPhone and iPad)
- Modern iOS version support (iOS 15+)
- SwiftUI-based interface
- Native Swift implementation

## Success Criteria
1. Accurate pose detection in various lighting conditions
2. Real-time performance (≥30 FPS) on target devices
3. Intuitive user interface
4. Stable video playback with overlay
5. Reliable camera capture

## Out of Scope (Initial Version)
- Pose recording/export
- Multiple model selection
- Advanced analytics
- Cloud processing
- Social sharing features

