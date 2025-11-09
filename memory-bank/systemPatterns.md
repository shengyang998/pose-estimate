# System Patterns

## Overall Architecture

### MVVM Pattern with SwiftUI
```
View Layer (SwiftUI)
    ↓
ViewModel Layer (ObservableObject)
    ↓
Model Layer (Data & Business Logic)
    ↓
Service Layer (Camera, ML, Video)
```

## Core Components

### 1. App Structure
- **PoseEstimateApp**: Main app entry point
- **RootView/ContentView**: Main navigation and mode selection
- **CameraView**: Real-time camera mode interface
- **VideoView**: Video analysis mode interface

### 2. Camera Module
**Purpose**: Handle real-time camera capture and frame processing

Components:
- `CameraManager`: Manages AVCaptureSession
  - Configure camera input
  - Handle frame capture
  - Provide video frames to processing pipeline
- `CameraViewModel`: SwiftUI bridge
  - Expose camera state to UI
  - Handle permissions
  - Control camera lifecycle

Data Flow:
```
Camera Hardware → AVCaptureSession → VideoDataOutput 
→ Frame Buffer → Pose Estimation → Rendering
```

### 3. Video Module
**Purpose**: Handle video file selection and playback

Components:
- `VideoPlayerManager`: Manages AVPlayer
  - Load video files
  - Control playback
  - Extract frames for processing
- `VideoViewModel`: SwiftUI bridge
  - Expose playback state
  - Handle video selection
  - Synchronize overlay with playback

Data Flow:
```
Video File → AVAsset → AVPlayer → Frame Extraction 
→ Pose Estimation → Overlay Rendering
```

### 4. Pose Estimation Module
**Purpose**: Process frames and detect human poses

Components:
- `PoseEstimator`: Core ML inference
  - Initialize Vision request
  - Process video frames
  - Extract keypoint data
  - Handle multiple person detection
- `PoseModel`: Data structures
  - Body keypoint definitions
  - Skeleton connections
  - Confidence scores

Processing Pipeline:
```
Video Frame (CVPixelBuffer)
    ↓
VNImageRequestHandler
    ↓
VNDetectHumanBodyPoseRequest
    ↓
VNRecognizedPointsObservation
    ↓
Parsed Keypoints (PoseModel)
```

### 5. Rendering Module
**Purpose**: Draw skeleton overlay on video frames

Components:
- `SkeletonRenderer`: Drawing logic
  - Convert keypoints to screen coordinates
  - Draw connections between joints
  - Draw joint points
  - Handle scaling and transformations
- `SkeletonView`: SwiftUI overlay
  - Display rendered skeleton
  - Update in real-time

Rendering Strategy:
```
Keypoints (normalized coordinates)
    ↓
Coordinate transformation (image → screen space)
    ↓
Drawing instructions (lines, circles)
    ↓
Canvas/Layer rendering
    ↓
UI overlay
```

## Key Design Patterns

### 1. Dependency Injection
Services are injected into ViewModels for testability:
```swift
class CameraViewModel: ObservableObject {
    private let cameraManager: CameraManager
    private let poseEstimator: PoseEstimator
    
    init(cameraManager: CameraManager, 
         poseEstimator: PoseEstimator) {
        // ...
    }
}
```

### 2. Protocol-Oriented Design
Define protocols for major components:
```swift
protocol FrameProcessor {
    func process(_ frame: CVPixelBuffer) async throws -> PoseResult
}

protocol VideoSource {
    var framePublisher: AnyPublisher<CVPixelBuffer, Never> { get }
}
```

### 3. Async/Await for Processing
Use modern Swift concurrency for ML processing:
```swift
func detectPose(in frame: CVPixelBuffer) async throws -> [Keypoint] {
    // Async Vision processing
}
```

### 4. Combine for State Management
Reactive updates for UI state changes:
```swift
@Published var detectedPose: PoseModel?
@Published var isProcessing: Bool = false
```

## Data Flow Architecture

### Real-time Camera Mode
```
User Opens App
    ↓
Request Camera Permission
    ↓
Initialize AVCaptureSession
    ↓
[Continuous Loop]
    Capture Frame → Detect Pose → Render Overlay → Display
```

### Video Analysis Mode
```
User Selects Video
    ↓
Load Video with AVPlayer
    ↓
[Playback Loop]
    Extract Current Frame → Detect Pose → Render Overlay → Display
    ↓
User Controls (Play/Pause/Seek)
```

## Component Relationships

### Dependency Graph
```
Views
  ├─ CameraView → CameraViewModel
  │                 ├─ CameraManager → AVFoundation
  │                 └─ PoseEstimator → Vision Framework
  │
  └─ VideoView → VideoViewModel
                   ├─ VideoPlayerManager → AVFoundation
                   └─ PoseEstimator → Vision Framework

Shared
  ├─ PoseEstimator (used by both modes)
  ├─ SkeletonRenderer (used by both modes)
  └─ PoseModel (data structure)
```

## Error Handling Strategy

### Error Types
- Camera permission errors
- Video loading errors
- ML processing errors
- Frame processing errors

### Error Handling Approach
```swift
enum PoseEstimationError: Error {
    case cameraPermissionDenied
    case videoLoadFailed
    case modelInitializationFailed
    case frameProcessingFailed
}

// Use Result type for operations that can fail
func detectPose() async -> Result<PoseModel, PoseEstimationError>
```

## Performance Optimization

### Strategies
1. **Frame Throttling**: Process every Nth frame if needed
2. **Background Processing**: ML inference on background queue
3. **Lazy Rendering**: Only render when pose changes
4. **Resource Pooling**: Reuse buffers and objects
5. **Metal Acceleration**: GPU rendering for overlays

### Memory Management
- Use weak references to prevent retain cycles
- Release camera resources when backgrounded
- Efficient buffer handling
- Clear video cache when switching modes

