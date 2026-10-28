//
//  ContentView.swift
//  Pomodoro
//
//  Created by Onur Arda on 18.10.2026.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = PomodoroViewModel()
    @State private var activeSheet: ActiveSheet?
    @State private var showSplash: Bool = true
    @Namespace private var phaseNamespace
    @Namespace private var ambientNamespace
    @Environment(\.scenePhase) private var scenePhase

    private enum ActiveSheet: String, Identifiable {
        case tasks
        case stats
        case settings

        var id: String { rawValue }
    }

    var body: some View {
        ZStack {
            // 1. Chronos Obsidian & Underworld Gradient Background
            backgroundGradient
                .ignoresSafeArea()

            // 2. Cosmic Chronos Stardust & Time Shards
            AmbientBubblesBackgroundView(
                phase: viewModel.currentPhase,
                isRunning: viewModel.isRunning
            )
            .ignoresSafeArea()

            // 3. Main Chronos Interface
            GeometryReader { proxy in
                let hasVolumeBar = viewModel.settings.ambientSound != .none
                let maxDialByWidth = proxy.size.width - 48
                let maxDialByHeight = proxy.size.height * (hasVolumeBar ? 0.37 : 0.41)
                let dialDiameter = min(296, max(210, min(maxDialByWidth, maxDialByHeight)))
                let isCompactHeight = proxy.size.height < 700

                VStack(spacing: isCompactHeight ? 8 : 10) {
                    chronosHeaderBar

                    chronosModeSelectorSection

                    Spacer(minLength: 2)

                    // Central Rotating Clockwork Gears + Golden Hourglass Dial
                    VStack(spacing: isCompactHeight ? 8 : 10) {
                        TimerRingView(
                            phase: viewModel.currentPhase,
                            progress: viewModel.progress,
                            formattedTime: viewModel.formattedTime,
                            isRunning: viewModel.isRunning,
                            isPaused: viewModel.isPaused,
                            completedInCycle: viewModel.completedFocusInCycle,
                            cycleTarget: viewModel.settings.sessionsBeforeLongBreak,
                            dialDiameter: dialDiameter
                        )

                        activeTaskPillButton
                    }

                    Spacer(minLength: 2)

                    // Chronos Playback Controls ("Zamanı Başlat" / "Zamanı Dondur" / "Zamanı Çöz")
                    chronosControlsBar

                    // Ambient Audio Bar ("Ortam: Kapalı | Zaman Çarkları | Yağmur | Akarsu | Kafe")
                    chronosAmbientBar

                    // Mythic Proverb Footer
                    chronosFooterQuote
                }
                .padding(.horizontal, 14)
                .padding(.top, 6)
                .padding(.bottom, 8)
                .frame(width: proxy.size.width, height: proxy.size.height)
            }

            // 4. Cinematic Chronos Splash Screen Overlay
            if showSplash {
                ChronosSplashScreenView {
                    withAnimation(.easeOut(duration: 0.45)) {
                        showSplash = false
                    }
                }
                .transition(.opacity)
                .zIndex(10)
            }
        }
        .preferredColorScheme(.dark)
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .tasks:
                TasksSheetView(viewModel: viewModel)
                    .presentationDetents([.fraction(0.82), .large])
                    .presentationDragIndicator(.visible)
            case .stats:
                StatsSheetView(viewModel: viewModel)
                    .presentationDetents([.fraction(0.82), .large])
                    .presentationDragIndicator(.visible)
            case .settings:
                SettingsSheetView(viewModel: viewModel)
                    .presentationDetents([.fraction(0.85), .large])
                    .presentationDragIndicator(.visible)
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                viewModel.syncWithCurrentTime()
            }
        }
    }

    // MARK: - Background
    private var backgroundGradient: some View {
        let bgColors = viewModel.settings.appTheme.backgroundColors
        return LinearGradient(
            colors: bgColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - 1. Top Chronos Navigation Bar (Port of Header.tsx)
    private var chronosHeaderBar: some View {
        HStack(spacing: 6) {
            // Left: Tasks Button with Uncompleted Badge
            Button {
                activeSheet = .tasks
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "hourglass")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(ChronosPalette.goldPrimary)

                    Text("Görevler")
                        .font(.system(size: 11.5, weight: .semibold, design: .serif))
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                        .fixedSize(horizontal: true, vertical: false)
                        .foregroundStyle(ChronosPalette.goldBright)

                    if viewModel.uncompletedTasksCount > 0 {
                        Text("\(viewModel.uncompletedTasksCount)")
                            .font(.system(size: 9.5, weight: .black, design: .monospaced))
                            .lineLimit(1)
                            .foregroundStyle(.black)
                            .frame(minWidth: 16, minHeight: 16)
                            .padding(.horizontal, 2)
                            .background(
                                Circle().fill(ChronosPalette.goldPrimary)
                            )
                    }
                }
                .padding(.horizontal, 9)
                .padding(.vertical, 7)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.black.opacity(0.45))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(ChronosPalette.goldAmber.opacity(0.32), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(.plain)

            Spacer(minLength: 4)

            // Center: CHRONOS • TITAN OF TIME Title
            VStack(spacing: 1) {
                Text("CHRONOS")
                    .font(.system(size: 16.5, weight: .black, design: .serif))
                    .tracking(2.6)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                ChronosPalette.goldBright,
                                ChronosPalette.goldPrimary,
                                ChronosPalette.jadeBright
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: ChronosPalette.goldAmber.opacity(0.45), radius: 8)

                Text("TITAN OF TIME")
                    .font(.system(size: 8, weight: .bold, design: .serif))
                    .tracking(2.0)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .foregroundStyle(ChronosPalette.goldPrimary.opacity(0.75))
            }
            .layoutPriority(1)

            Spacer(minLength: 4)

            // Right Action Buttons: Stats, Theme Toggle, Settings
            HStack(spacing: 5) {
                headerIconButton(systemName: "chart.bar.fill", label: "İstatistik") {
                    activeSheet = .stats
                }

                headerIconButton(
                    systemName: viewModel.settings.appTheme == .chronos ? "moon.stars.fill" : "sun.max.fill",
                    label: "Tema"
                ) {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        viewModel.toggleQuickTheme()
                    }
                }

                headerIconButton(systemName: "gearshape.fill", label: "Ayarlar") {
                    activeSheet = .settings
                }
            }
        }
    }

    private func headerIconButton(systemName: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 12.5, weight: .semibold))
                .foregroundStyle(ChronosPalette.goldBright.opacity(0.9))
                .frame(width: 32, height: 32)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.black.opacity(0.45))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .strokeBorder(ChronosPalette.goldAmber.opacity(0.32), lineWidth: 1)
                        )
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }

    // MARK: - 2. Mode Selector & DÖNGÜ Indicator (Port of ModeSelector.tsx)
    private var chronosModeSelectorSection: some View {
        let totalRounds = max(1, viewModel.settings.sessionsBeforeLongBreak)
        let isManyRounds = totalRounds > 6
        return VStack(spacing: 6) {
            // Segmented Track
            HStack(spacing: 4) {
                ForEach(PomodoroPhase.allCases) { phase in
                    let isSelected = viewModel.currentPhase == phase
                    Button {
                        withAnimation(.spring(response: 0.36, dampingFraction: 0.8)) {
                            viewModel.selectPhase(phase)
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: phase.symbolName)
                                .font(.system(size: 11, weight: .bold))
                            Text(phase.title)
                                .font(.system(size: 12, weight: isSelected ? .bold : .medium, design: .serif))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        .foregroundStyle(
                            isSelected
                                ? Color.white
                                : ChronosPalette.goldBright.opacity(0.72)
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
                        .background {
                            if isSelected {
                                RoundedRectangle(cornerRadius: 11, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [phase.primaryColor, phase.secondaryColor],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .shadow(color: phase.primaryColor.opacity(0.4), radius: 6, x: 0, y: 2)
                                    .matchedGeometryEffect(id: "chronosPhaseTab", in: phaseNamespace)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(4)
            .background(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .fill(Color.black.opacity(0.45))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .strokeBorder(ChronosPalette.goldAmber.opacity(0.32), lineWidth: 1)
                    )
            )

            // Rounds Indicator (`DÖNGÜ 1 / 4` + Status Pill)
            HStack(spacing: 8) {
                HStack(spacing: 5) {
                    Text("DÖNGÜ \(viewModel.currentRoundNumber) / \(totalRounds)")
                        .font(.system(size: 10, weight: .semibold, design: .serif))
                        .tracking(1.0)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .fixedSize(horizontal: true, vertical: false)
                        .foregroundStyle(ChronosPalette.goldBright.opacity(0.82))

                    HStack(spacing: isManyRounds ? 2.5 : 3.5) {
                        ForEach(1...totalRounds, id: \.self) { index in
                            let isCurrent = index == viewModel.currentRoundNumber
                            let isCompleted = index < viewModel.currentRoundNumber
                            Capsule()
                                .fill(
                                    isCurrent
                                        ? ChronosPalette.goldPrimary
                                        : isCompleted
                                        ? ChronosPalette.goldAmber.opacity(0.75)
                                        : ChronosPalette.goldAmber.opacity(0.22)
                                )
                                .frame(
                                    width: isManyRounds
                                        ? (isCurrent ? 10 : 5)
                                        : (isCurrent ? 14 : (isCompleted ? 9 : 7)),
                                    height: 5
                                )
                                .shadow(color: isCurrent ? ChronosPalette.goldPrimary.opacity(0.8) : .clear, radius: 4)
                        }
                    }
                }

                // Mode Status Badge
                HStack(spacing: 5) {
                    Circle()
                        .fill(viewModel.currentPhase.primaryColor)
                        .frame(width: 6, height: 6)
                    Text(viewModel.currentPhase.statusText(isRunning: viewModel.isRunning, isPaused: viewModel.isPaused).uppercased())
                        .font(.system(size: 9, weight: .bold, design: .serif))
                        .tracking(1.0)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .foregroundStyle(viewModel.currentPhase.sandTopColor)
                }
                .padding(.horizontal, 9)
                .padding(.vertical, 3.5)
                .background(
                    Capsule()
                        .fill(viewModel.currentPhase.primaryColor.opacity(0.16))
                        .overlay(
                            Capsule()
                                .strokeBorder(viewModel.currentPhase.primaryColor.opacity(0.42), lineWidth: 1)
                        )
                )
            }
        }
    }

    // MARK: - 3. Active Task Docked Pill (Port of TimerDisplay.tsx Active Task Bar)
    private var activeTaskPillButton: some View {
        Button {
            activeSheet = .tasks
        } label: {
            HStack(spacing: 7) {
                Image(systemName: "scope")
                    .font(.system(size: 12.5, weight: .bold))
                    .foregroundStyle(ChronosPalette.goldPrimary)

                if let task = viewModel.selectedTask {
                    Text(task.title)
                        .font(.system(size: 12, weight: .semibold, design: .serif))
                        .foregroundStyle(ChronosPalette.goldBright)
                        .lineLimit(1)
                        .truncationMode(.tail)

                    Text("\(task.completedPomodoros)/\(task.estimatedPomodoros)")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        .foregroundStyle(ChronosPalette.goldBright)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(ChronosPalette.goldAmber.opacity(0.22))
                                .overlay(
                                    Capsule()
                                        .strokeBorder(ChronosPalette.goldAmber.opacity(0.4), lineWidth: 0.8)
                                )
                        )
                } else {
                    Text("Odaklanılacak bir görev seçin...")
                        .font(.system(size: 12, weight: .medium, design: .serif))
                        .italic()
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                        .foregroundStyle(ChronosPalette.goldPrimary.opacity(0.75))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(
                Capsule()
                    .fill(Color.black.opacity(0.55))
                    .overlay(
                        Capsule()
                            .strokeBorder(ChronosPalette.goldAmber.opacity(0.35), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - 4. Chronos Playback Controls (Port of TimerControls.tsx)
    private var chronosControlsBar: some View {
        HStack(spacing: 14) {
            // Rewind Time (Reset) Button
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    viewModel.resetTimer()
                }
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(ChronosPalette.goldBright)
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.black.opacity(0.55))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .strokeBorder(ChronosPalette.goldAmber.opacity(0.35), lineWidth: 1)
                            )
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Zamanı Sıfırla")

            // Primary Freeze / Unleash Time Button
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                    viewModel.toggleTimer()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: viewModel.isRunning ? "pause.fill" : "play.fill")
                        .font(.system(size: 15, weight: .black))

                    Text(primaryActionLabel)
                        .font(.system(size: 14.5, weight: .black, design: .serif))
                        .tracking(0.6)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .foregroundStyle(viewModel.currentPhase == .longBreak ? Color.white : Color(red: 0.05, green: 0.04, blue: 0.02))
                .padding(.horizontal, 24)
                .frame(minWidth: 168, minHeight: 46, maxHeight: 46)
                .background(
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    viewModel.currentPhase.primaryColor,
                                    viewModel.currentPhase.secondaryColor
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 15, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.38), lineWidth: 1)
                        )
                )
                .shadow(color: viewModel.currentPhase.primaryColor.opacity(0.42), radius: 10, x: 0, y: 4)
            }
            .buttonStyle(.plain)

            // Fast Forward (Skip) Button
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    viewModel.skipToNextPhase()
                }
            } label: {
                Image(systemName: "forward.end.fill")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(ChronosPalette.goldBright)
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.black.opacity(0.55))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .strokeBorder(ChronosPalette.goldAmber.opacity(0.35), lineWidth: 1)
                            )
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Sonraki Seansa Geç")
        }
    }

    private var primaryActionLabel: String {
        if viewModel.isRunning {
            return "Zamanı Dondur"
        }
        if viewModel.isPaused {
            return "Zamanı Çöz"
        }
        return "Zamanı Başlat"
    }

    // MARK: - 5. Ambient Sound Bar (Port of AmbientBar.tsx)
    private var chronosAmbientBar: some View {
        VStack(spacing: 5) {
            HStack(spacing: 6) {
                HStack(spacing: 4) {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.system(size: 10.5, weight: .bold))
                        .foregroundStyle(ChronosPalette.goldPrimary)
                    Text("Ortam:")
                        .font(.system(size: 11, weight: .semibold, design: .serif))
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        .foregroundStyle(ChronosPalette.goldBright.opacity(0.8))
                }
                .padding(.leading, 4)

                // Segmented Ambient Options
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 3) {
                        ForEach(ChronosAmbientSound.allCases) { option in
                            let isSelected = viewModel.settings.ambientSound == option
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    viewModel.selectAmbientSound(option)
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: option.symbolName)
                                        .font(.system(size: 10, weight: .bold))
                                    Text(option.title)
                                        .font(.system(size: 10.5, weight: isSelected ? .bold : .medium, design: .serif))
                                        .lineLimit(1)
                                }
                                .fixedSize(horizontal: true, vertical: false)
                                .foregroundStyle(
                                    isSelected
                                        ? Color.black
                                        : ChronosPalette.goldBright.opacity(0.75)
                                )
                                .padding(.horizontal, 8)
                                .padding(.vertical, 5.5)
                                .background {
                                    if isSelected {
                                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                                            .fill(
                                                LinearGradient(
                                                    colors: [ChronosPalette.goldBronze, ChronosPalette.goldPrimary],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .matchedGeometryEffect(id: "ambientPill", in: ambientNamespace)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(3)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color.black.opacity(0.55))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .strokeBorder(ChronosPalette.goldAmber.opacity(0.22), lineWidth: 1)
                            )
                    )
                }
            }

            if viewModel.settings.ambientSound != .none {
                HStack(spacing: 8) {
                    Image(systemName: "speaker.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(ChronosPalette.goldPrimary.opacity(0.7))

                    Slider(
                        value: Binding(
                            get: { Double(viewModel.settings.ambientVolume) },
                            set: { viewModel.updateAmbientVolume(Int($0)) }
                        ),
                        in: 5...100,
                        step: 1
                    )
                    .tint(ChronosPalette.goldAmber)
                    .frame(maxWidth: 150)

                    Text("%\(viewModel.settings.ambientVolume)")
                        .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        .foregroundStyle(ChronosPalette.goldBright)
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 2)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(Color.black.opacity(0.42))
                .overlay(
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .strokeBorder(ChronosPalette.goldAmber.opacity(0.3), lineWidth: 1)
                )
        )
    }

    // MARK: - 6. Chronos Mythic Proverb Footer
    private var chronosFooterQuote: some View {
        HStack(spacing: 6) {
            Text("⏳")
                .font(.system(size: 10))
            Text("\"Zaman, ölümlülerin en kıymetli hazinesidir; her saniye bir zaferdir.\"")
                .font(.system(size: 10, weight: .regular, design: .serif))
                .italic()
                .foregroundStyle(ChronosPalette.goldBright.opacity(0.55))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text("⚜")
                .font(.system(size: 10))
                .foregroundStyle(ChronosPalette.goldPrimary.opacity(0.6))
        }
        .padding(.top, 1)
    }
}

// MARK: - Chronos Splash Screen View (Port of SplashScreen.tsx)
private struct ChronosSplashScreenView: View {
    let onFinish: () -> Void

    @State private var progress: Double = 0.0
    @State private var isCompleted: Bool = false

    private var statusMessage: String {
        if progress < 40 {
            return "Zaman Çarkları Kuruluyor..."
        } else if progress < 85 {
            return "Zamanın Kumları Akıyor..."
        } else {
            return "Mühür Açılıyor..."
        }
    }

    var body: some View {
        ZStack {
            Color(red: 0.020, green: 0.031, blue: 0.047) // #05080c
                .ignoresSafeArea()

            RadialGradient(
                colors: [
                    ChronosPalette.jadePrimary.opacity(0.18),
                    ChronosPalette.goldAmber.opacity(0.12),
                    Color.clear
                ],
                center: .center,
                startRadius: 20,
                endRadius: 320
            )
            .ignoresSafeArea()

            VStack(spacing: 14) {
                ChronosHourglassView(
                    phase: .focus,
                    remainingRatio: max(0.15, 1.0 - progress / 100.0),
                    isRunning: true,
                    width: 74,
                    height: 102
                )
                .padding(.bottom, 6)

                Text("CHRONOS")
                    .font(.system(size: 40, weight: .black, design: .serif))
                    .tracking(5)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                ChronosPalette.goldBright,
                                ChronosPalette.goldPrimary,
                                ChronosPalette.jadeBright
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: ChronosPalette.goldAmber.opacity(0.55), radius: 18)

                Text("TITAN OF TIME • ZAMANIN EFENDİSİ")
                    .font(.system(size: 11, weight: .semibold, design: .serif))
                    .tracking(2.4)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(ChronosPalette.goldBright.opacity(0.8))
                    .padding(.bottom, 18)

                // Golden Progress Bar
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.black.opacity(0.85))
                        .frame(width: 240, height: 7)
                        .overlay(
                            Capsule()
                                .strokeBorder(ChronosPalette.goldAmber.opacity(0.45), lineWidth: 1)
                        )

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    ChronosPalette.goldAmber,
                                    ChronosPalette.goldPrimary,
                                    ChronosPalette.jadeBright
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(8, 238 * CGFloat(min(100, progress) / 100.0)), height: 5)
                        .padding(.horizontal, 1)
                        .shadow(color: ChronosPalette.goldPrimary.opacity(0.9), radius: 6)
                }

                Text(statusMessage)
                    .font(.system(size: 12, weight: .medium, design: .serif))
                    .tracking(1.0)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .foregroundStyle(ChronosPalette.goldBright.opacity(0.75))
                    .padding(.top, 4)

                Text("(Geçmek için dokunun)")
                    .font(.system(size: 10, weight: .regular, design: .serif))
                    .tracking(1.5)
                    .lineLimit(1)
                    .foregroundStyle(ChronosPalette.goldPrimary.opacity(0.45))
                    .padding(.top, 14)
            }
            .padding(.horizontal, 24)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            completeSplash()
        }
        .task {
            let steps = 40
            for step in 1...steps {
                if isCompleted { break }
                try? await Task.sleep(for: .milliseconds(45))
                withAnimation(.linear(duration: 0.04)) {
                    progress = Double(step) * (100.0 / Double(steps))
                }
            }
            try? await Task.sleep(for: .milliseconds(200))
            completeSplash()
        }
    }

    private func completeSplash() {
        guard !isCompleted else { return }
        isCompleted = true
        onFinish()
    }
}

#Preview {
    ContentView()
}
