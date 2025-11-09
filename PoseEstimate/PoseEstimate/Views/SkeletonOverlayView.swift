//
//  SkeletonRenderer.swift
//  PoseEstimate
//
//  Created by Soleil Yu on 2025/11/9.
//

import SwiftUI
import Vision

/// Responsible for rendering skeleton overlay from pose data
struct SkeletonRenderer {
    
    // MARK: - Properties
    
    let lineWidth: CGFloat
    let jointRadius: CGFloat
    let lineColor: Color
    let jointColor: Color
    let orientation: VideoOrientation
    
    init(
        lineWidth: CGFloat = 3.0,
        jointRadius: CGFloat = 6.0,
        lineColor: Color = .green,
        jointColor: Color = .yellow,
        orientation: VideoOrientation = .portrait
    ) {
        self.lineWidth = lineWidth
        self.jointRadius = jointRadius
        self.lineColor = lineColor
        self.jointColor = jointColor
        self.orientation = orientation
    }
    
    // MARK: - Public Methods
    
    /// Render skeleton on a SwiftUI Canvas
    func render(pose: PoseModel, in context: GraphicsContext, size: CGSize) {
        // Draw connections first (so joints appear on top)
        for connection in SkeletonConnection.allConnections {
            drawConnection(connection, pose: pose, in: context, size: size)
        }
        
        // Draw joints
        for (_, keypoint) in pose.keypoints where keypoint.isReliable {
            drawJoint(keypoint, in: context, size: size)
        }
    }
    
    // MARK: - Private Methods
    
    /// Transform normalized coordinates (0-1, origin bottom-left) to screen coordinates
    private func transformPoint(_ point: CGPoint, to size: CGSize) -> CGPoint {
        // Use orientation-aware transformation
        return orientation.transformPoint(point, viewSize: size)
    }
    
    /// Draw a connection line between two joints
    private func drawConnection(
        _ connection: SkeletonConnection,
        pose: PoseModel,
        in context: GraphicsContext,
        size: CGSize
    ) {
        guard let fromKeypoint = pose.keypoint(for: connection.from),
              let toKeypoint = pose.keypoint(for: connection.to),
              fromKeypoint.isReliable && toKeypoint.isReliable else {
            return
        }
        
        let fromPoint = transformPoint(fromKeypoint.point, to: size)
        let toPoint = transformPoint(toKeypoint.point, to: size)
        
        var path = Path()
        path.move(to: fromPoint)
        path.addLine(to: toPoint)
        
        context.stroke(
            path,
            with: .color(lineColor),
            lineWidth: lineWidth
        )
    }
    
    /// Draw a joint point
    private func drawJoint(
        _ keypoint: Keypoint,
        in context: GraphicsContext,
        size: CGSize
    ) {
        let point = transformPoint(keypoint.point, to: size)
        let rect = CGRect(
            x: point.x - jointRadius,
            y: point.y - jointRadius,
            width: jointRadius * 2,
            height: jointRadius * 2
        )
        
        context.fill(
            Circle().path(in: rect),
            with: .color(jointColor)
        )
        
        // Add a border to make joints more visible
        context.stroke(
            Circle().path(in: rect),
            with: .color(.white),
            lineWidth: 1.0
        )
    }
}

/// SwiftUI view for rendering skeleton overlay
struct SkeletonOverlayView: View {
    let pose: PoseModel?
    let orientation: VideoOrientation
    let renderer: SkeletonRenderer
    
    init(
        pose: PoseModel?, 
        orientation: VideoOrientation = .portrait,
        lineWidth: CGFloat = 3.0,
        jointRadius: CGFloat = 6.0,
        lineColor: Color = .green,
        jointColor: Color = .yellow
    ) {
        self.pose = pose
        self.orientation = orientation
        self.renderer = SkeletonRenderer(
            lineWidth: lineWidth,
            jointRadius: jointRadius,
            lineColor: lineColor,
            jointColor: jointColor,
            orientation: orientation
        )
    }
    
    var body: some View {
        Canvas { context, size in
            guard let pose = pose else { return }
            renderer.render(pose: pose, in: context, size: size)
        }
    }
}

