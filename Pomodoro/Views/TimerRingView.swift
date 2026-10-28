//
//  TimerRingView.swift
//  Pomodoro
//
//  Created by Onur Arda on 18.10.2026.
//

import SwiftUI

// MARK: - Chronos Clockwork Gears & Astrolabe Timer Dial
struct TimerRingView: View {
    let phase: PomodoroPhase
    let progress: Double
    let formattedTime: String
    let isRunning: Bool
    var isPaused: Bool = false
    let completedInCycle: Int
    let cycleTarget: Int

    private let romanNumerals: [String] = [
        "XII", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI"
    ]

    var dialDiameter: CGFloat = 288

    var body: some View {
        let scaleFactor = dialDiameter / 324.0
        ZStack {
            // 1. Main Circular Obsidian Container with Golden Border & Outer Breathing Aura
            Circle()
                .fill(Color(red: 0.027, green: 0.043, blue: 0.063).opacity(0.88)) // #070b10
                .frame(width: dialDiameter, height: dialDiameter)
                .background(
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    phase.primaryColor.opacity(isRunning ? 0.24 : 0.10),
                                    ChronosPalette.jadePrimary.opacity(isRunning ? 0.10 : 0.03),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 40 * scaleFactor,
                                endRadius: 180 * scaleFactor
                            )
                        )
                        .frame(width: dialDiameter * 1.12, height: dialDiameter * 1.12)
                        .allowsHitTesting(false)
                )
                .overlay(
                    Circle()
                        .strokeBorder(ChronosPalette.goldAmber.opacity(0.35), lineWidth: 1.5)
                )
                .shadow(color: .black.opacity(0.75), radius: 18, x: 0, y: 8)
                .shadow(color: phase.primaryColor.opacity(isRunning ? 0.22 : 0.08), radius: 14)

            // 3. Animated Clockwork Gears & Astrolabe SVG Geometry (500x500 coordinate space)
            TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
                let t = timeline.date.timeIntervalSinceReferenceDate
                let speedFactor = isRunning ? 1.0 : 0.22
                // Outer 36-tooth gear: 360 deg per 60s clockwise
                let outerAngle = (t * 6.0 * speedFactor).truncatingRemainder(dividingBy: 360.0)
                // Inner 24-tooth astrolabe gear: 360 deg per 45s counter-clockwise
                let innerAngle = -(t * 8.0 * speedFactor).truncatingRemainder(dividingBy: 360.0)

                ZStack {
                    Canvas { context, size in
                        let scale = size.width / 500.0
                        let center = CGPoint(x: size.width * 0.5, y: size.height * 0.5)

                        let goldGrad = Gradient(colors: [
                            Color(red: 0.996, green: 0.929, blue: 0.580), // #feed94
                            Color(red: 0.961, green: 0.620, blue: 0.043), // #f59e0b
                            Color(red: 0.573, green: 0.251, blue: 0.055), // #92400e
                            Color(red: 0.992, green: 0.878, blue: 0.278)  // #fde047
                        ])

                        let bronzeGrad = Gradient(colors: [
                            Color(red: 0.851, green: 0.467, blue: 0.024), // #d97706
                            Color(red: 0.471, green: 0.208, blue: 0.059), // #78350f
                            Color(red: 0.271, green: 0.102, blue: 0.012)  // #451a03
                        ])

                        // --- LAYER 1: Outer 36-Tooth Clockwise Gear ---
                        context.drawLayer { layer in
                            layer.opacity = isRunning ? 0.68 : 0.42
                            layer.translateBy(x: center.x, y: center.y)
                            layer.rotate(by: .degrees(outerAngle))
                            layer.translateBy(x: -center.x, y: -center.y)

                            let outerTeeth = Self.makeGearPath(
                                cx: center.x,
                                cy: center.y,
                                teeth: 36,
                                rOuter: 246.0 * scale,
                                rInner: 226.0 * scale
                            )
                            layer.fill(
                                outerTeeth,
                                with: .linearGradient(
                                    bronzeGrad,
                                    startPoint: CGPoint(x: 0, y: 0),
                                    endPoint: CGPoint(x: size.width, y: size.height)
                                )
                            )
                            layer.stroke(
                                outerTeeth,
                                with: .linearGradient(
                                    goldGrad,
                                    startPoint: CGPoint(x: 0, y: 0),
                                    endPoint: CGPoint(x: size.width, y: size.height)
                                ),
                                lineWidth: 1.4 * scale
                            )
                        }

                        // --- LAYER 2: Inner 24-Tooth Counter-Clockwise Astrolabe Gear ---
                        context.drawLayer { layer in
                            layer.opacity = isRunning ? 0.58 : 0.35
                            layer.translateBy(x: center.x, y: center.y)
                            layer.rotate(by: .degrees(innerAngle))
                            layer.translateBy(x: -center.x, y: -center.y)

                            let innerTeeth = Self.makeGearPath(
                                cx: center.x,
                                cy: center.y,
                                teeth: 24,
                                rOuter: 168.0 * scale,
                                rInner: 150.0 * scale
                            )
                            layer.fill(innerTeeth, with: .color(ChronosPalette.goldBronze.opacity(0.18)))
                            layer.stroke(
                                innerTeeth,
                                with: .linearGradient(
                                    goldGrad,
                                    startPoint: CGPoint(x: 80 * scale, y: 80 * scale),
                                    endPoint: CGPoint(x: 420 * scale, y: 420 * scale)
                                ),
                                lineWidth: 1.5 * scale
                            )

                            let dashedRing = Path(ellipseIn: CGRect(
                                x: center.x - 146 * scale,
                                y: center.y - 146 * scale,
                                width: 292 * scale,
                                height: 292 * scale
                            ))
                            layer.stroke(
                                dashedRing,
                                with: .color(ChronosPalette.goldPrimary.opacity(0.75)),
                                style: StrokeStyle(lineWidth: 1.8 * scale, dash: [8 * scale, 6 * scale])
                            )

                            // 8 Astrolabe Spokes
                            for i in 0..<8 {
                                let rad = Double(i) * 45.0 * .pi / 180.0
                                var spoke = Path()
                                spoke.move(to: CGPoint(
                                    x: center.x + CGFloat(cos(rad)) * 75 * scale,
                                    y: center.y + CGFloat(sin(rad)) * 75 * scale
                                ))
                                spoke.addLine(to: CGPoint(
                                    x: center.x + CGFloat(cos(rad)) * 145 * scale,
                                    y: center.y + CGFloat(sin(rad)) * 145 * scale
                                ))
                                layer.stroke(
                                    spoke,
                                    with: .color(ChronosPalette.goldPrimary.opacity(0.45)),
                                    lineWidth: 2.0 * scale
                                )
                            }
                        }

                        // --- LAYER 3: Static Golden Frame Rings & 12 Roman Numeral Mini-Gear Plates ---
                        let ring225 = Path(ellipseIn: CGRect(
                            x: center.x - 225 * scale,
                            y: center.y - 225 * scale,
                            width: 450 * scale,
                            height: 450 * scale
                        ))
                        context.stroke(
                            ring225,
                            with: .linearGradient(goldGrad, startPoint: .zero, endPoint: CGPoint(x: size.width, y: size.height)),
                            lineWidth: 4.5 * scale
                        )

                        let ring215 = Path(ellipseIn: CGRect(
                            x: center.x - 215 * scale,
                            y: center.y - 215 * scale,
                            width: 430 * scale,
                            height: 430 * scale
                        ))
                        context.stroke(
                            ring215,
                            with: .color(ChronosPalette.goldPrimary.opacity(0.55)),
                            style: StrokeStyle(lineWidth: 1.8 * scale, dash: [3 * scale, 7 * scale])
                        )

                        let ring174 = Path(ellipseIn: CGRect(
                            x: center.x - 174 * scale,
                            y: center.y - 174 * scale,
                            width: 348 * scale,
                            height: 348 * scale
                        ))
                        context.stroke(
                            ring174,
                            with: .linearGradient(goldGrad, startPoint: .zero, endPoint: CGPoint(x: size.width, y: size.height)),
                            lineWidth: 2.4 * scale
                        )

                        // 12 Radial Hour Markers & Mini-Gear Cartouches
                        for i in 0..<12 {
                            let angle = (Double(i) * 30.0 - 90.0) * .pi / 180.0
                            let cosA = CGFloat(cos(angle))
                            let sinA = CGFloat(sin(angle))

                            var tick = Path()
                            tick.move(to: CGPoint(x: center.x + cosA * 174 * scale, y: center.y + sinA * 174 * scale))
                            tick.addLine(to: CGPoint(x: center.x + cosA * 222 * scale, y: center.y + sinA * 222 * scale))
                            context.stroke(
                                tick,
                                with: .color(ChronosPalette.goldPrimary.opacity(0.32)),
                                lineWidth: 1.4 * scale
                            )

                            let mx = center.x + cosA * 195 * scale
                            let my = center.y + sinA * 195 * scale
                            let miniGear = Self.makeGearPath(
                                cx: mx,
                                cy: my,
                                teeth: 8,
                                rOuter: 15.0 * scale,
                                rInner: 12.0 * scale
                            )
                            context.fill(
                                miniGear,
                                with: .linearGradient(
                                    goldGrad,
                                    startPoint: CGPoint(x: mx - 15 * scale, y: my - 15 * scale),
                                    endPoint: CGPoint(x: mx + 15 * scale, y: my + 15 * scale)
                                )
                            )
                            context.stroke(miniGear, with: .color(ChronosPalette.goldDeep), lineWidth: 0.8 * scale)

                            let cartouche = Path(ellipseIn: CGRect(
                                x: mx - 10.5 * scale,
                                y: my - 10.5 * scale,
                                width: 21.0 * scale,
                                height: 21.0 * scale
                            ))
                            context.fill(cartouche, with: .color(Color(red: 0.047, green: 0.063, blue: 0.090)))
                            context.stroke(cartouche, with: .color(ChronosPalette.goldPrimary.opacity(0.75)), lineWidth: 0.8 * scale)
                        }

                        // --- LAYER 4: Central Obsidian Altar Disc (r=140) ---
                        let altarRect = CGRect(
                            x: center.x - 140 * scale,
                            y: center.y - 140 * scale,
                            width: 280 * scale,
                            height: 280 * scale
                        )
                        let altarPath = Path(ellipseIn: altarRect)
                        context.fill(
                            altarPath,
                            with: .radialGradient(
                                Gradient(colors: [
                                    Color(red: 0.043, green: 0.071, blue: 0.106), // #0b121b
                                    Color(red: 0.020, green: 0.031, blue: 0.047), // #05080c
                                    Color(red: 0.008, green: 0.016, blue: 0.027)  // #020407
                                ]),
                                center: center,
                                startRadius: 10 * scale,
                                endRadius: 140 * scale
                            )
                        )
                        context.stroke(
                            altarPath,
                            with: .linearGradient(goldGrad, startPoint: altarRect.origin, endPoint: CGPoint(x: altarRect.maxX, y: altarRect.maxY)),
                            lineWidth: 2.4 * scale
                        )

                        // Progress Arc Ring along the Altar Rim (r=136)
                        let clampedProgress = max(0.005, min(1.0, progress))
                        var progressArc = Path()
                        progressArc.addArc(
                            center: center,
                            radius: 136 * scale,
                            startAngle: .degrees(-90),
                            endAngle: .degrees(-90 + clampedProgress * 360.0),
                            clockwise: false
                        )
                        context.stroke(
                            progressArc,
                            with: .color(phase.primaryColor.opacity(0.88)),
                            style: StrokeStyle(lineWidth: 3.2 * scale, lineCap: .round)
                        )

                        // Inner Decorative Dashed Ring (r=130)
                        let innerDashed = Path(ellipseIn: CGRect(
                            x: center.x - 130 * scale,
                            y: center.y - 130 * scale,
                            width: 260 * scale,
                            height: 260 * scale
                        ))
                        context.stroke(
                            innerDashed,
                            with: .color(ChronosPalette.goldPrimary.opacity(0.35)),
                            style: StrokeStyle(lineWidth: 1.0 * scale, dash: [4 * scale, 6 * scale])
                        )

                        // 4 Cardinal Star Studs on the Altar Rim (0, 90, 180, 270)
                        for deg in [0.0, 90.0, 180.0, 270.0] {
                            let rad = deg * .pi / 180.0
                            let sx = center.x + CGFloat(cos(rad)) * 140 * scale
                            let sy = center.y + CGFloat(sin(rad)) * 140 * scale
                            let stud = Path(ellipseIn: CGRect(x: sx - 3.5 * scale, y: sy - 3.5 * scale, width: 7 * scale, height: 7 * scale))
                            context.fill(stud, with: .color(ChronosPalette.goldBright))
                        }

                        // --- LAYER 5: Chronos Elapsed-Time Scythe Pointer Hand ---
                        let handAngleDeg = progress * 360.0
                        context.drawLayer { layer in
                            layer.opacity = isRunning ? 0.65 : 0.32
                            layer.translateBy(x: center.x, y: center.y)
                            layer.rotate(by: .degrees(handAngleDeg))
                            layer.translateBy(x: -center.x, y: -center.y)

                            var handLine = Path()
                            handLine.move(to: CGPoint(x: center.x, y: center.y))
                            handLine.addLine(to: CGPoint(x: center.x, y: center.y - 126 * scale))
                            layer.stroke(
                                handLine,
                                with: .linearGradient(
                                    goldGrad,
                                    startPoint: CGPoint(x: center.x, y: center.y),
                                    endPoint: CGPoint(x: center.x, y: center.y - 126 * scale)
                                ),
                                style: StrokeStyle(lineWidth: 2.2 * scale, lineCap: .round)
                            )

                            var tipDiamond = Path()
                            tipDiamond.move(to: CGPoint(x: center.x, y: center.y - 135 * scale))
                            tipDiamond.addLine(to: CGPoint(x: center.x - 4.5 * scale, y: center.y - 121 * scale))
                            tipDiamond.addLine(to: CGPoint(x: center.x + 4.5 * scale, y: center.y - 121 * scale))
                            tipDiamond.closeSubpath()
                            layer.fill(tipDiamond, with: .color(ChronosPalette.goldBright))
                        }
                    }

                    // Crisp Roman Numeral Labels placed over the 12 Mini-Gear Cartouches
                    ForEach(0..<12, id: \.self) { index in
                        let angle = (Double(index) * 30.0 - 90.0) * .pi / 180.0
                        let r = (dialDiameter / 500.0) * 195.0
                        Text(romanNumerals[index])
                            .font(.system(size: max(7.0, 8.2 * scaleFactor), weight: .black, design: .serif))
                            .lineLimit(1)
                            .fixedSize()
                            .foregroundStyle(ChronosPalette.goldBright)
                            .offset(
                                x: CGFloat(cos(angle)) * r,
                                y: CGFloat(sin(angle)) * r
                            )
                    }
                }
                .frame(width: dialDiameter, height: dialDiameter)
            }

            // 4. Center Chronos Altar Content: Ornate Hourglass + Digital Countdown + Emblem
            VStack(spacing: 2 * scaleFactor) {
                ChronosHourglassView(
                    phase: phase,
                    remainingRatio: 1.0 - progress,
                    isRunning: isRunning,
                    width: 56 * scaleFactor,
                    height: 76 * scaleFactor
                )

                // Digital Countdown Readout
                Text(formattedTime)
                    .font(.system(size: 33 * scaleFactor, weight: .black, design: .serif))
                    .monospacedDigit()
                    .tracking(1.5 * scaleFactor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color.white,
                                ChronosPalette.goldBright,
                                phase.primaryColor
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: .black.opacity(0.95), radius: 6, x: 0, y: 2)
                    .shadow(color: phase.primaryColor.opacity(isRunning ? 0.55 : 0.25), radius: 10)
                    .contentTransition(.numericText(countsDown: true))
                    .animation(.spring(response: 0.3, dampingFraction: 0.85), value: formattedTime)

                // Chronos Emblem Divider (`✦ CHRONOS ✦`)
                HStack(spacing: 4 * scaleFactor) {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.clear, ChronosPalette.goldAmber.opacity(0.6)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 14 * scaleFactor, height: 1)

                    Text("✦ CHRONOS ✦")
                        .font(.system(size: max(6.8, 7.5 * scaleFactor), weight: .bold, design: .serif))
                        .tracking(1.6 * scaleFactor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .fixedSize()
                        .foregroundStyle(ChronosPalette.goldPrimary.opacity(0.78))

                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [ChronosPalette.goldAmber.opacity(0.6), .clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 14 * scaleFactor, height: 1)
                }
            }
            .frame(maxWidth: dialDiameter * 0.48)
        }
        .frame(width: dialDiameter, height: dialDiameter)
    }

    // MARK: - Procedural Gear Tooth Path Builder (Port of generateGearPath)
    private static func makeGearPath(
        cx: CGFloat,
        cy: CGFloat,
        teeth: Int,
        rOuter: CGFloat,
        rInner: CGFloat
    ) -> Path {
        var path = Path()
        guard teeth > 0 else { return path }
        let step = (2.0 * Double.pi) / Double(teeth)

        for i in 0..<teeth {
            let a0 = Double(i) * step
            let a1 = a0 + step * 0.22
            let a2 = a0 + step * 0.32
            let a3 = a0 + step * 0.68
            let a4 = a0 + step * 0.78

            let p0 = CGPoint(x: cx + CGFloat(cos(a0)) * rInner, y: cy + CGFloat(sin(a0)) * rInner)
            let p1 = CGPoint(x: cx + CGFloat(cos(a1)) * rInner, y: cy + CGFloat(sin(a1)) * rInner)
            let p2 = CGPoint(x: cx + CGFloat(cos(a2)) * rOuter, y: cy + CGFloat(sin(a2)) * rOuter)
            let p3 = CGPoint(x: cx + CGFloat(cos(a3)) * rOuter, y: cy + CGFloat(sin(a3)) * rOuter)
            let p4 = CGPoint(x: cx + CGFloat(cos(a4)) * rInner, y: cy + CGFloat(sin(a4)) * rInner)

            if i == 0 {
                path.move(to: p0)
            } else {
                path.addLine(to: p0)
            }
            path.addLine(to: p1)
            path.addLine(to: p2)
            path.addLine(to: p3)
            path.addLine(to: p4)
        }
        path.closeSubpath()
        return path
    }
}
