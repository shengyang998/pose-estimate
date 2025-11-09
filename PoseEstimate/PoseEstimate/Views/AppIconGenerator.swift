//
//  AppIconGenerator.swift
//  PoseEstimate
//
//  Created by Soleil Yu on 2025/11/9.
//
//  This is a helper view to generate the app icon
//  Run this in preview, take screenshot, and add to Assets
//

import SwiftUI

struct AppIconGenerator: View {
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(red: 0.2, green: 0.8, blue: 0.5), Color(red: 0.1, green: 0.6, blue: 0.9)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Simple skeleton figure
            Canvas { context, size in
                let scale = size.width / 1024.0
                let lineWidth = 30.0 * scale
                let jointRadius = 20.0 * scale
                
                // Helper to draw point
                func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
                    CGPoint(x: x * scale, y: y * scale)
                }
                
                // Draw connections
                let connections: [(CGPoint, CGPoint)] = [
                    // Head to neck
                    (point(512, 250), point(512, 350)),
                    // Neck to shoulders
                    (point(512, 350), point(380, 400)),
                    (point(512, 350), point(644, 400)),
                    // Shoulders to elbows
                    (point(380, 400), point(320, 550)),
                    (point(644, 400), point(704, 550)),
                    // Elbows to wrists
                    (point(320, 550), point(280, 680)),
                    (point(704, 550), point(744, 680)),
                    // Neck to hips
                    (point(512, 350), point(512, 600)),
                    // Hips
                    (point(512, 600), point(440, 600)),
                    (point(512, 600), point(584, 600)),
                    // Hips to knees
                    (point(440, 600), point(420, 780)),
                    (point(584, 600), point(604, 780)),
                    // Knees to ankles
                    (point(420, 780), point(400, 920)),
                    (point(604, 780), point(624, 920))
                ]
                
                // Draw lines
                for (from, to) in connections {
                    var path = Path()
                    path.move(to: from)
                    path.addLine(to: to)
                    context.stroke(path, with: .color(.white), lineWidth: lineWidth)
                }
                
                // Draw joints
                let joints: [CGPoint] = [
                    point(512, 250),  // Head
                    point(512, 350),  // Neck
                    point(380, 400), point(644, 400),  // Shoulders
                    point(320, 550), point(704, 550),  // Elbows
                    point(280, 680), point(744, 680),  // Wrists
                    point(512, 600),  // Hip center
                    point(440, 600), point(584, 600),  // Hips
                    point(420, 780), point(604, 780),  // Knees
                    point(400, 920), point(624, 920)   // Ankles
                ]
                
                for joint in joints {
                    let rect = CGRect(
                        x: joint.x - jointRadius,
                        y: joint.y - jointRadius,
                        width: jointRadius * 2,
                        height: jointRadius * 2
                    )
                    context.fill(Circle().path(in: rect), with: .color(.yellow))
                    context.stroke(Circle().path(in: rect), with: .color(.white), lineWidth: 4 * scale)
                }
            }
        }
    }
}

#Preview("App Icon 1024x1024") {
    AppIconGenerator()
        .frame(width: 1024, height: 1024)
}

