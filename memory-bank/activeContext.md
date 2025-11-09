# Active Context

## Current Status
**Date**: November 9, 2025
**Phase**: Project Initialization
**State**: Fresh project with basic SwiftUI setup

## What We Have Now

### Project Structure
- Basic Xcode project created: `PoseEstimate`
- SwiftUI app entry point: `PoseEstimateApp.swift`
- Placeholder view: `ContentView.swift` (currently shows "Hello, world!")
- Test targets set up (unit tests and UI tests)
- Memory Bank initialized with complete documentation

### Infrastructure
- Memory Bank documentation complete
- Project structure ready for development
- No external dependencies yet (using native iOS frameworks)

## Current Work Focus

### Immediate Next Steps (Priority Order)

1. **Set Up Info.plist Permissions**
   - Add NSCameraUsageDescription
   - Add NSPhotoLibraryUsageDescription

2. **Create Core Data Models**
   - Define `Keypoint` structure
   - Define `PoseModel` with body keypoints
   - Define skeleton connection pairs

3. **Implement Pose Estimation Service**
   - Create `PoseEstimator` class
   - Initialize Vision framework request (VNDetectHumanBodyPoseRequest)
   - Implement frame processing method
   - Parse recognized points into keypoint model

4. **Implement Camera Module**
   - Create `CameraManager` for AVCaptureSession
   - Set up video data output
   - Handle frame capture
   - Create `CameraViewModel` for SwiftUI

5. **Implement Basic Skeleton Rendering**
   - Create `SkeletonRenderer` 
   - Implement coordinate transformation
   - Draw connections and joints
   - Create SwiftUI overlay view

6. **Build Camera View UI**
   - Replace ContentView with camera interface
   - Add camera preview
   - Add skeleton overlay
   - Handle permissions UI

7. **Implement Video Module**
   - Create `VideoPlayerManager`
   - Handle video file selection
   - Extract frames during playback
   - Create `VideoViewModel`

8. **Build Video View UI**
   - Create video player interface
   - Add playback controls
   - Add skeleton overlay for video
   - Handle video selection UI

9. **Add Mode Selection**
   - Create main navigation view
   - Add tab or segmented control for Camera/Video modes
   - Implement mode switching

10. **Testing & Optimization**
    - Test on real device
    - Optimize performance
    - Fine-tune rendering
    - Test with various videos and poses

## Active Decisions & Considerations

### Technical Decisions Needed
1. **Rendering Approach**: SwiftUI Canvas vs UIKit overlay vs Metal
   - Consideration: Performance vs ease of implementation
   - Recommendation: Start with SwiftUI Canvas, optimize later if needed

2. **Frame Processing Rate**: Process every frame vs throttling
   - Consideration: Performance vs smoothness
   - Recommendation: Start with every frame, add throttling if needed

3. **Multi-person Detection**: Single person vs multiple people
   - Consideration: Complexity vs functionality
   - Recommendation: Start with single person, add multi-person later

4. **Video Frame Extraction**: Real-time during playback vs pre-processing
   - Consideration: Memory vs latency
   - Recommendation: Real-time extraction during playback

### UI/UX Decisions Needed
1. Color scheme for skeleton overlay (high contrast, customizable?)
2. Confidence threshold display (show low-confidence keypoints?)
3. Settings panel needed for initial version?
4. Onboarding flow for permissions?

## Known Constraints
- Must maintain 30+ FPS for real-time mode
- Battery consumption should be reasonable
- App size considerations for ML model
- iOS 15+ compatibility requirement

## Recent Changes
- November 9, 2025: Project created
- November 9, 2025: Memory Bank initialized

## Questions to Resolve
1. Should we support custom ML models or stick with Vision framework?
2. Do we need recording/export functionality in v1?
3. Should we support both front and back cameras?
4. Any specific video formats we need to prioritize?

## Resources & References
- [Apple Vision Framework Documentation](https://developer.apple.com/documentation/vision)
- [AVFoundation Documentation](https://developer.apple.com/av-foundation/)
- [Human Body Pose Detection](https://developer.apple.com/documentation/vision/detecting_human_body_poses_in_images)

## Next Session Priorities
Focus on building the core pose estimation and camera modules, as these are the foundation for both main features.

