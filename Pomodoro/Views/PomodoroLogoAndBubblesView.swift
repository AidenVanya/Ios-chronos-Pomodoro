//
//  PomodoroLogoAndBubblesView.swift
//  Pomodoro
//
//  Created by Onur Arda on 19.10.2026.
//

import SwiftUI

// MARK: - Chronos Ornate Golden Hourglass (Port of ChronosHourglass.tsx)
struct ChronosHourglassView: View {
    let phase: PomodoroPhase
    let remainingRatio: Double
    let isRunning: Bool
    var width: CGFloat = 104
    var height: CGFloat = 143

    @State private var streamDashPhase: CGFloat = 0
    @State private var sparklePulse: Bool = false

    private var clampedTop: Double {
        max(0.0, min(1.0, remainingRatio))
    }

    private var clampedBottom: Double {
        max(0.0, min(1.0, 1.0 - remainingRatio))
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: !isRunning)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                let sx = size.width / 160.0
                let sy = size.height / 220.0

                func pt(_ x: Double, _ y: Double) -> CGPoint {
                    CGPoint(x: x * sx, y: y * sy)
                }

                let goldGradient = Gradient(colors: [
                    Color(red: 0.996, green: 0.941, blue: 0.541), // #fef08a
                    Color(red: 0.961, green: 0.620, blue: 0.043), // #f59e0b
                    Color(red: 0.706, green: 0.325, blue: 0.035), // #b45309
                    Color(red: 0.984, green: 0.749, blue: 0.141)  // #fbbf24
                ])

                let sandShading = Gradient(colors: [
                    phase.sandTopColor,
                    phase.sandMidColor,
                    phase.sandDarkColor
                ])

                // 1. Subtle Ambient Glow behind the Hourglass
                let glowRect = CGRect(
                    x: 20 * sx,
                    y: 35 * sy,
                    width: 120 * sx,
                    height: 150 * sy
                )
                context.fill(
                    Path(ellipseIn: glowRect),
                    with: .radialGradient(
                        Gradient(colors: [
                            phase.sandMidColor.opacity(isRunning ? 0.28 : 0.14),
                            phase.sandDarkColor.opacity(0.0)
                        ]),
                        center: pt(80, 110),
                        startRadius: 4 * sx,
                        endRadius: 65 * sx
                    )
                )

                // 2. Glass Chamber Paths (Upper & Lower Bulbs)
                var upperBulb = Path()
                upperBulb.move(to: pt(42, 34))
                upperBulb.addCurve(to: pt(76, 108), control1: pt(42, 76), control2: pt(68, 96))
                upperBulb.addLine(to: pt(84, 108))
                upperBulb.addCurve(to: pt(118, 34), control1: pt(92, 96), control2: pt(118, 76))
                upperBulb.closeSubpath()

                var lowerBulb = Path()
                lowerBulb.move(to: pt(76, 112))
                lowerBulb.addCurve(to: pt(42, 186), control1: pt(68, 124), control2: pt(42, 144))
                lowerBulb.addLine(to: pt(118, 186))
                lowerBulb.addCurve(to: pt(84, 112), control1: pt(118, 144), control2: pt(92, 124))
                lowerBulb.closeSubpath()

                // Dark Glass Interior Backing
                context.fill(upperBulb, with: .color(Color(red: 0.03, green: 0.05, blue: 0.08).opacity(0.62)))
                context.fill(lowerBulb, with: .color(Color(red: 0.03, green: 0.05, blue: 0.08).opacity(0.62)))

                // 3. Upper Chamber Sand (Draining) clipped to upper bulb
                if clampedTop > 0.005 {
                    let topSandHeight = clampedTop * 64.0
                    let topSandY = 105.0 - topSandHeight
                    let topWidthHalf = 4.0 + clampedTop * 32.0

                    context.drawLayer { layer in
                        layer.clip(to: upperBulb)
                        var topSand = Path()
                        topSand.move(to: pt(80.0 - topWidthHalf, topSandY))
                        topSand.addQuadCurve(
                            to: pt(80.0 + topWidthHalf, topSandY),
                            control: pt(80.0, topSandY + ( isRunning ? 4.5 : 1.5 ))
                        )
                        topSand.addLine(to: pt(84.0, 108.0))
                        topSand.addLine(to: pt(76.0, 108.0))
                        topSand.closeSubpath()

                        layer.fill(
                            topSand,
                            with: .linearGradient(
                                sandShading,
                                startPoint: pt(45, topSandY),
                                endPoint: pt(115, 108)
                            )
                        )
                    }
                }

                // 4. Falling Sand Stream & Sparkles (Active when running)
                if isRunning && clampedTop > 0.0 {
                    var streamLine = Path()
                    streamLine.move(to: pt(80, 108))
                    streamLine.addLine(to: pt(80, 178))

                    let dashOffset = CGFloat((t * 38.0).truncatingRemainder(dividingBy: 12.0))
                    context.stroke(
                        streamLine,
                        with: .color(phase.sandTopColor),
                        style: StrokeStyle(
                            lineWidth: 2.2 * sx,
                            lineCap: .round,
                            dash: [4 * sy, 3 * sy],
                            dashPhase: -dashOffset
                        )
                    )

                    // Floating sand dust sparkles inside lower chamber
                    let p1y = 132.0 + sin(t * 5.0) * 6.0
                    let p2y = 148.0 + cos(t * 4.2) * 7.0
                    let p3y = 160.0 + sin(t * 6.1) * 5.0

                    context.fill(
                        Path(ellipseIn: CGRect(x: 73 * sx, y: p1y * sy, width: 2.6 * sx, height: 2.6 * sy)),
                        with: .color(phase.sandTopColor.opacity(0.85))
                    )
                    context.fill(
                        Path(ellipseIn: CGRect(x: 85 * sx, y: p2y * sy, width: 2.2 * sx, height: 2.2 * sy)),
                        with: .color(phase.sandMidColor.opacity(0.80))
                    )
                    context.fill(
                        Path(ellipseIn: CGRect(x: 76 * sx, y: p3y * sy, width: 3.0 * sx, height: 3.0 * sy)),
                        with: .color(phase.sandTopColor.opacity(0.75))
                    )
                }

                // 5. Lower Chamber Sand (Accumulating Mound) clipped to lower bulb
                if clampedBottom > 0.005 {
                    let bottomSandHeight = clampedBottom * 64.0
                    let bottomSandPeakY = 179.0 - bottomSandHeight
                    let bottomBaseY = 185.0

                    context.drawLayer { layer in
                        layer.clip(to: lowerBulb)
                        var bottomSand = Path()
                        bottomSand.move(to: pt(38, bottomBaseY))
                        bottomSand.addQuadCurve(
                            to: pt(80, bottomSandPeakY),
                            control: pt(64, bottomSandPeakY + 8)
                        )
                        bottomSand.addQuadCurve(
                            to: pt(122, bottomBaseY),
                            control: pt(96, bottomSandPeakY + 8)
                        )
                        bottomSand.closeSubpath()

                        layer.fill(
                            bottomSand,
                            with: .linearGradient(
                                sandShading,
                                startPoint: pt(42, bottomSandPeakY),
                                endPoint: pt(118, bottomBaseY)
                            )
                        )
                    }
                }

                // 6. Glass Chamber Outlines & Specular Reflections
                context.stroke(
                    upperBulb,
                    with: .linearGradient(
                        goldGradient,
                        startPoint: pt(40, 34),
                        endPoint: pt(120, 108)
                    ),
                    lineWidth: 2.0 * sx
                )
                context.stroke(
                    lowerBulb,
                    with: .linearGradient(
                        goldGradient,
                        startPoint: pt(40, 112),
                        endPoint: pt(120, 186)
                    ),
                    lineWidth: 2.0 * sx
                )

                // Specular glass highlights
                var upperShine = Path()
                upperShine.move(to: pt(49, 42))
                upperShine.addCurve(to: pt(72, 98), control1: pt(50, 68), control2: pt(64, 88))
                context.stroke(
                    upperShine,
                    with: .color(.white.opacity(0.32)),
                    style: StrokeStyle(lineWidth: 2.2 * sx, lineCap: .round)
                )

                var lowerShine = Path()
                lowerShine.move(to: pt(72, 122))
                lowerShine.addCurve(to: pt(49, 176), control1: pt(64, 134), control2: pt(50, 154))
                context.stroke(
                    lowerShine,
                    with: .color(.white.opacity(0.24)),
                    style: StrokeStyle(lineWidth: 2.0 * sx, lineCap: .round)
                )

                // 7. Ornate Side Pillars with Rhombus Gems
                for pillarX in [30.0, 130.0] {
                    var pillarLine = Path()
                    pillarLine.move(to: pt(pillarX, 32))
                    pillarLine.addLine(to: pt(pillarX, 188))
                    context.stroke(
                        pillarLine,
                        with: .linearGradient(goldGradient, startPoint: pt(pillarX, 32), endPoint: pt(pillarX, 188)),
                        style: StrokeStyle(lineWidth: 3.5 * sx, lineCap: .round)
                    )

                    // Center Pillar Rhombus Gem
                    var rhombus = Path()
                    rhombus.move(to: pt(pillarX, 102))
                    rhombus.addLine(to: pt(pillarX + 5, 110))
                    rhombus.addLine(to: pt(pillarX, 118))
                    rhombus.addLine(to: pt(pillarX - 5, 110))
                    rhombus.closeSubpath()
                    context.fill(rhombus, with: .color(ChronosPalette.goldPrimary))
                    context.stroke(rhombus, with: .color(ChronosPalette.goldBright), lineWidth: 1.0 * sx)
                }

                // 8. Center Waist Golden Seal Ring
                let waistRect = CGRect(x: 68 * sx, y: 106 * sy, width: 24 * sx, height: 8 * sy)
                let waistPath = Path(roundedRect: waistRect, cornerRadius: 4 * sy)
                context.fill(
                    waistPath,
                    with: .linearGradient(goldGradient, startPoint: pt(68, 106), endPoint: pt(92, 114))
                )
                context.stroke(waistPath, with: .color(ChronosPalette.goldBright), lineWidth: 1.0 * sx)

                // 9. Top & Bottom Royal Titan Pedestals
                let topCapUpper = Path(roundedRect: CGRect(x: 20 * sx, y: 20 * sy, width: 120 * sx, height: 8 * sy), cornerRadius: 3 * sy)
                let topCapLower = Path(roundedRect: CGRect(x: 26 * sx, y: 28 * sy, width: 108 * sx, height: 6 * sy), cornerRadius: 2 * sy)
                context.fill(topCapUpper, with: .linearGradient(goldGradient, startPoint: pt(20, 20), endPoint: pt(140, 28)))
                context.fill(topCapLower, with: .color(ChronosPalette.goldBronze))

                let botCapUpper = Path(roundedRect: CGRect(x: 26 * sx, y: 186 * sy, width: 108 * sx, height: 6 * sy), cornerRadius: 2 * sy)
                let botCapLower = Path(roundedRect: CGRect(x: 20 * sx, y: 192 * sy, width: 120 * sx, height: 8 * sy), cornerRadius: 3 * sy)
                context.fill(botCapUpper, with: .color(ChronosPalette.goldBronze))
                context.fill(botCapLower, with: .linearGradient(goldGradient, startPoint: pt(20, 192), endPoint: pt(140, 200)))

                // Curved Chronos Scythe / Crown Arch on Top & Bottom
                var topArch = Path()
                topArch.move(to: pt(52, 20))
                topArch.addQuadCurve(to: pt(108, 20), control: pt(80, 6))
                context.stroke(
                    topArch,
                    with: .linearGradient(goldGradient, startPoint: pt(52, 12), endPoint: pt(108, 12)),
                    style: StrokeStyle(lineWidth: 2.5 * sx, lineCap: .round)
                )

                var botArch = Path()
                botArch.move(to: pt(52, 200))
                botArch.addQuadCurve(to: pt(108, 200), control: pt(80, 214))
                context.stroke(
                    botArch,
                    with: .linearGradient(goldGradient, startPoint: pt(52, 208), endPoint: pt(108, 208)),
                    style: StrokeStyle(lineWidth: 2.5 * sx, lineCap: .round)
                )

                // Top & Bottom Pedestal Jewels (mode colored)
                let topGem = Path(ellipseIn: CGRect(x: 76.5 * sx, y: 10.5 * sy, width: 7 * sx, height: 7 * sy))
                let botGem = Path(ellipseIn: CGRect(x: 76.5 * sx, y: 202.5 * sy, width: 7 * sx, height: 7 * sy))
                context.fill(topGem, with: .color(phase.sandMidColor))
                context.stroke(topGem, with: .color(ChronosPalette.goldBright), lineWidth: 1.0 * sx)
                context.fill(botGem, with: .color(phase.sandMidColor))
                context.stroke(botGem, with: .color(ChronosPalette.goldBright), lineWidth: 1.0 * sx)
            }
        }
        .frame(width: width, height: height)
        .shadow(color: phase.primaryColor.opacity(isRunning ? 0.45 : 0.22), radius: isRunning ? 14 : 7)
    }
}

// MARK: - Legacy Wrapper (PomodoroLogoView -> Chronos Mini Hourglass Emblem)
struct PomodoroLogoView: View {
    let phase: PomodoroPhase
    let isRunning: Bool
    var size: CGFloat = 56
    var showExpression: Bool = true

    var body: some View {
        ChronosHourglassView(
            phase: phase,
            remainingRatio: 0.65,
            isRunning: isRunning,
            width: size * 0.78,
            height: size * 1.05
        )
    }
}

// MARK: - Cosmic Chronos Stardust & Time Shards Background
struct AmbientBubblesBackgroundView: View {
    let phase: PomodoroPhase
    let isRunning: Bool

    private let particles: [ChronosStardustSpec] = [
        ChronosStardustSpec(xRatio: 0.12, yRatio: 0.18, radius: 2.2, speed: 0.9, delay: 0.0, isJade: false),
        ChronosStardustSpec(xRatio: 0.86, yRatio: 0.24, radius: 2.8, speed: 1.1, delay: 1.4, isJade: true),
        ChronosStardustSpec(xRatio: 0.22, yRatio: 0.74, radius: 1.8, speed: 0.8, delay: 2.3, isJade: false),
        ChronosStardustSpec(xRatio: 0.78, yRatio: 0.68, radius: 2.5, speed: 1.2, delay: 0.7, isJade: true),
        ChronosStardustSpec(xRatio: 0.48, yRatio: 0.12, radius: 2.0, speed: 1.0, delay: 3.1, isJade: false),
        ChronosStardustSpec(xRatio: 0.08, yRatio: 0.52, radius: 2.4, speed: 0.7, delay: 4.0, isJade: true),
        ChronosStardustSpec(xRatio: 0.92, yRatio: 0.46, radius: 1.9, speed: 1.3, delay: 1.9, isJade: false),
        ChronosStardustSpec(xRatio: 0.34, yRatio: 0.88, radius: 2.6, speed: 0.95, delay: 2.8, isJade: false),
        ChronosStardustSpec(xRatio: 0.66, yRatio: 0.84, radius: 2.1, speed: 1.15, delay: 3.6, isJade: true)
    ]

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 24.0)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                // Central radial mode aura
                let center = CGPoint(x: size.width * 0.5, y: size.height * 0.45)
                let auraRadius = max(size.width, size.height) * 0.62
                let auraRect = CGRect(
                    x: center.x - auraRadius,
                    y: center.y - auraRadius,
                    width: auraRadius * 2,
                    height: auraRadius * 2
                )
                context.fill(
                    Path(ellipseIn: auraRect),
                    with: .radialGradient(
                        Gradient(colors: [
                            phase.primaryColor.opacity(isRunning ? 0.16 : 0.09),
                            ChronosPalette.jadePrimary.opacity(0.04),
                            Color.clear
                        ]),
                        center: center,
                        startRadius: 10,
                        endRadius: auraRadius
                    )
                )

                // Floating Chronos time shards & golden stardust
                for p in particles {
                    let phaseTime = t * p.speed + p.delay
                    let driftY = sin(phaseTime) * 18.0
                    let driftX = cos(phaseTime * 0.7) * 10.0
                    let alpha = 0.25 + 0.55 * (0.5 + 0.5 * sin(phaseTime * 1.4))

                    let x = size.width * p.xRatio + CGFloat(driftX)
                    let y = size.height * p.yRatio + CGFloat(driftY)
                    let color = p.isJade ? ChronosPalette.jadeBright : ChronosPalette.goldPrimary

                    let glowRect = CGRect(x: x - p.radius * 3, y: y - p.radius * 3, width: p.radius * 6, height: p.radius * 6)
                    context.fill(
                        Path(ellipseIn: glowRect),
                        with: .radialGradient(
                            Gradient(colors: [color.opacity(alpha * 0.45), .clear]),
                            center: CGPoint(x: x, y: y),
                            startRadius: 0,
                            endRadius: p.radius * 3
                        )
                    )

                    let coreRect = CGRect(x: x - p.radius, y: y - p.radius, width: p.radius * 2, height: p.radius * 2)
                    context.fill(
                        Path(ellipseIn: coreRect),
                        with: .color(color.opacity(alpha))
                    )
                }
            }
        }
        .allowsHitTesting(false)
    }
}

private struct ChronosStardustSpec {
    let xRatio: CGFloat
    let yRatio: CGFloat
    let radius: CGFloat
    let speed: Double
    let delay: Double
    let isJade: Bool
}
