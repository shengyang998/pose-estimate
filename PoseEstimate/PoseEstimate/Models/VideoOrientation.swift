//
//  VideoOrientation.swift
//  PoseEstimate
//
//  Created by Soleil Yu on 2025/11/9.
//

import Foundation
import CoreGraphics

/// Video orientation for coordinate transformation
enum VideoOrientation {
    case portrait
    case portraitUpsideDown
    case landscapeLeft
    case landscapeRight
    
    /// Determine orientation from transform matrix
    static func from(transform: CGAffineTransform) -> VideoOrientation {
        // Check transform matrix to determine orientation
        // Reference: https://developer.apple.com/documentation/avfoundation/avassettrack/1389837-preferredtransform
        
        print("VideoOrientation: transform = a:\(transform.a) b:\(transform.b) c:\(transform.c) d:\(transform.d) tx:\(transform.tx) ty:\(transform.ty)")
        
        if transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0 {
            print("VideoOrientation: Detected portraitUpsideDown")
            return .portraitUpsideDown
        } else if transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0 {
            print("VideoOrientation: Detected portrait")
            return .portrait
        } else if transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0 {
            print("VideoOrientation: Detected landscapeRight")
            return .landscapeRight
        } else if transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0 {
            print("VideoOrientation: Detected landscapeLeft")
            return .landscapeLeft
        } else {
            print("VideoOrientation: Unknown transform, defaulting to portrait")
            return .portrait
        }
    }
    
    /// Transform point from Vision coordinates to screen coordinates considering orientation
    func transformPoint(_ point: CGPoint, viewSize: CGSize) -> CGPoint {
        // Vision framework coordinates: normalized (0-1), origin at bottom-left
        // For portrait videos shot on iPhone: the raw video data is actually landscape (sensor orientation)
        // preferredTransform rotates it to portrait for display
        // Vision processes the raw data, so we need to apply the same rotation
        
        let result: CGPoint
        
        switch self {
        case .portrait:
            // Portrait video: raw data is landscape, rotated 90° counter-clockwise
            // Vision coords are based on landscape raw data
            // Transform: x,y in landscape -> y,(1-x) in portrait display
            result = CGPoint(
                x: point.y * viewSize.width,
                y: (1 - point.x) * viewSize.height
            )
            
        case .portraitUpsideDown:
            // Portrait upside down: rotated 90° clockwise from landscape
            result = CGPoint(
                x: (1 - point.y) * viewSize.width,
                y: point.x * viewSize.height
            )
            
        case .landscapeRight:
            // Landscape right (home button on right)
            result = CGPoint(
                x: point.x * viewSize.width,
                y: (1 - point.y) * viewSize.height
            )
            
        case .landscapeLeft:
            // Landscape left (home button on left)  
            result = CGPoint(
                x: (1 - point.x) * viewSize.width,
                y: point.y * viewSize.height
            )
        }
        
        return result
    }
}

