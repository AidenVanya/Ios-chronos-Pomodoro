//
//  PomodoroViewModel.swift
//  Pomodoro
//
//  Created by Onur Arda on 18.10.2026.
//

import SwiftUI
import Foundation
import UserNotifications
import AVFoundation
import AudioToolbox
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Chronos Synthesizer & Ambient Sound Engine
private final class ChronosAudioBackend: @unchecked Sendable {
    private let queue = DispatchQueue(label: "com.chronos.pomodoro.audio", qos: .userInitiated)
    private let engine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
    private var isSessionConfigured = false
    private var isEngineConfigured = false

    private func ensureEngineRunningOnQueue() {
        #if os(iOS)
        if !isSessionConfigured {
            let session = AVAudioSession.sharedInstance()
            try? session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try? session.setActive(true)
            isSessionConfigured = true
        }
        #endif
        if !isEngineConfigured {
            engine.attach(playerNode)
            engine.connect(playerNode, to: engine.mainMixerNode, format: format)
            isEngineConfigured = true
        }
        if !engine.isRunning {
            try? engine.start()
        }
    }

    func stop() {
        queue.async { [weak self] in
            guard let self, self.isEngineConfigured else { return }
            self.playerNode.stop()
        }
    }

    func playSwitchTone(isModeSwitch: Bool) {
        queue.async { [weak self] in
            guard let self else { return }
            self.ensureEngineRunningOnQueue()
            let sampleRate = Float(self.format.sampleRate)
            let duration: Float = isModeSwitch ? 0.22 : 0.14
            let frameCount = AVAudioFrameCount(sampleRate * duration)
            guard let buffer = AVAudioPCMBuffer(pcmFormat: self.format, frameCapacity: frameCount) else { return }
            buffer.frameLength = frameCount

            guard let samples = buffer.floatChannelData?[0] else { return }
            let startFreq: Float = isModeSwitch ? 587.33 : 780.0
            let endFreq: Float = isModeSwitch ? 880.0 : 440.0
            var phase: Float = 0

            for i in 0..<Int(frameCount) {
                let t = Float(i) / sampleRate
                let progress = min(1.0, t / 0.08)
                let freq = startFreq + (endFreq - startFreq) * progress
                phase += 2.0 * .pi * freq / sampleRate
                let env = exp(-t * (isModeSwitch ? 14.0 : 22.0))
                samples[i] = sin(phase) * env * 0.12
            }

            if !self.playerNode.isPlaying {
                self.playerNode.play()
            }
            self.playerNode.scheduleBuffer(buffer, completionHandler: nil)
        }
    }

    func playBell(theme: ChronosSoundTheme, volumePercent: Int) {
        let volume = max(0.0, min(1.0, Float(volumePercent) / 100.0))
        guard volume > 0.01 else { return }

        queue.async { [weak self] in
            guard let self else { return }
            self.ensureEngineRunningOnQueue()

            let sampleRate = Float(self.format.sampleRate)
            let duration: Float = 3.2
            let frameCount = AVAudioFrameCount(sampleRate * duration)
            guard let buffer = AVAudioPCMBuffer(pcmFormat: self.format, frameCapacity: frameCount) else { return }
            buffer.frameLength = frameCount
            guard let samples = buffer.floatChannelData?[0] else { return }

            let partials: [(freq: Float, gain: Float, decay: Float)]
            switch theme {
            case .chronosBell:
                let base: Float = 164.81 // E3 Titan Bronze Bell
                partials = [
                    (82.4, 0.45, 1.4),
                    (base, 0.65, 1.6),
                    (base * 1.5, 0.40, 2.0),
                    (base * 2.0, 0.30, 2.4),
                    (base * 2.76, 0.22, 3.0),
                    (base * 4.15, 0.12, 4.2)
                ]
            case .zenBell:
                partials = [
                    (440.0, 0.55, 1.6),
                    (882.0, 0.25, 2.2),
                    (1324.0, 0.15, 2.8),
                    (1768.0, 0.08, 3.4)
                ]
            case .singingBowl:
                partials = [
                    (396.0, 0.50, 1.3),
                    (397.8, 0.35, 1.4),
                    (595.0, 0.25, 2.0),
                    (1089.0, 0.12, 2.8)
                ]
            case .digital:
                partials = [
                    (659.25, 0.45, 4.5),
                    (880.0, 0.45, 3.0)
                ]
            case .marimba:
                partials = [
                    (523.25, 0.50, 4.0),
                    (659.25, 0.40, 3.8),
                    (783.99, 0.35, 3.5),
                    (1046.5, 0.30, 3.2)
                ]
            }

            for i in 0..<Int(frameCount) {
                let t = Float(i) / sampleRate
                let attack = min(1.0, t / 0.015)
                var sum: Float = 0
                for p in partials {
                    let env = exp(-t * p.decay)
                    sum += sin(2.0 * .pi * p.freq * t) * p.gain * env
                }
                samples[i] = max(-0.95, min(0.95, sum * attack * volume * 0.45))
            }

            if !self.playerNode.isPlaying {
                self.playerNode.play()
            }
            self.playerNode.scheduleBuffer(buffer, completionHandler: nil)
        }
    }

    func playClockworkTick(isTick: Bool, volume: Float) {
        guard volume > 0.01 else { return }
        queue.async { [weak self] in
            guard let self else { return }
            self.ensureEngineRunningOnQueue()

            let sampleRate = Float(self.format.sampleRate)
            let duration: Float = 0.065
            let frameCount = AVAudioFrameCount(sampleRate * duration)
            guard let buffer = AVAudioPCMBuffer(pcmFormat: self.format, frameCapacity: frameCount),
                  let samples = buffer.floatChannelData?[0] else { return }
            buffer.frameLength = frameCount

            let baseFreq: Float = isTick ? 1180.0 : 880.0
            let pingFreq: Float = isTick ? 2200.0 : 1760.0

            for i in 0..<Int(frameCount) {
                let t = Float(i) / sampleRate
                let clickEnv = exp(-t * 95.0)
                let pingEnv = exp(-t * 48.0)
                let click = sin(2.0 * .pi * (baseFreq * exp(-t * 25.0)) * t) * clickEnv * 0.25
                let ping = sin(2.0 * .pi * pingFreq * t) * pingEnv * 0.06
                samples[i] = (click + ping) * volume
            }

            if !self.playerNode.isPlaying {
                self.playerNode.play()
            }
            self.playerNode.scheduleBuffer(buffer, completionHandler: nil)
        }
    }

    func playSoothingNoiseLoop(for sound: ChronosAmbientSound, volume: Float) {
        guard volume > 0.01 else { return }
        queue.async { [weak self] in
            guard let self else { return }
            self.ensureEngineRunningOnQueue()

            let sampleRate = Float(self.format.sampleRate)
            let duration: Float = 2.0
            let frameCount = AVAudioFrameCount(sampleRate * duration)
            guard let buffer = AVAudioPCMBuffer(pcmFormat: self.format, frameCapacity: frameCount),
                  let samples = buffer.floatChannelData?[0] else { return }
            buffer.frameLength = frameCount

            var lastOut: Float = 0
            let alpha: Float = {
                switch sound {
                case .rain: return 0.12
                case .stream: return 0.06
                case .cafe: return 0.035
                default: return 0.08
                }
            }()

            for i in 0..<Int(frameCount) {
                let t = Float(i) / sampleRate
                let white = Float.random(in: -1.0...1.0)
                lastOut = lastOut + alpha * (white - lastOut)

                // Gentle envelope at buffer edges to avoid clicks
                let fadeIn = min(1.0, t / 0.08)
                let fadeOut = min(1.0, (duration - t) / 0.08)
                let mod: Float = sound == .stream ? (0.85 + 0.15 * sin(2.0 * .pi * 0.5 * t)) : 1.0
                samples[i] = lastOut * fadeIn * fadeOut * mod * volume * 0.14
            }

            if !self.playerNode.isPlaying {
                self.playerNode.play()
            }
            self.playerNode.scheduleBuffer(buffer, completionHandler: nil)
        }
    }
}

@MainActor
final class ChronosSoundEngine {
    static let shared = ChronosSoundEngine()

    private let backend = ChronosAudioBackend()
    private var ambientTask: Task<Void, Never>?
    private var currentAmbient: ChronosAmbientSound = .none
    private var currentVolume: Float = 0.5
    private var clockworkStep: Int = 0

    private init() {}

    func playSwitchTone(isModeSwitch: Bool) {
        backend.playSwitchTone(isModeSwitch: isModeSwitch)
    }

    func playBell(theme: ChronosSoundTheme, volumePercent: Int) {
        backend.playBell(theme: theme, volumePercent: volumePercent)
    }

    func updateAmbient(sound: ChronosAmbientSound, volumePercent: Int) {
        currentVolume = max(0.0, min(1.0, Float(volumePercent) / 100.0))
        if sound == .none {
            stopAmbient()
            return
        }

        if currentAmbient == sound, ambientTask != nil {
            return
        }

        stopAmbient()
        currentAmbient = sound

        switch sound {
        case .none:
            break
        case .clockwork:
            triggerClockworkTick()
            ambientTask = Task { [weak self] in
                while !Task.isCancelled {
                    try? await Task.sleep(for: .seconds(1.0))
                    guard !Task.isCancelled, let self, self.currentAmbient == .clockwork else { break }
                    self.triggerClockworkTick()
                }
            }
        case .rain, .stream, .cafe:
            scheduleSoothingNoiseLoop(for: sound)
            ambientTask = Task { [weak self] in
                while !Task.isCancelled {
                    try? await Task.sleep(for: .seconds(2.0))
                    guard !Task.isCancelled, let self, self.currentAmbient == sound else { break }
                    self.scheduleSoothingNoiseLoop(for: sound)
                }
            }
        }
    }

    func stopAmbient() {
        ambientTask?.cancel()
        ambientTask = nil
        currentAmbient = .none
        backend.stop()
    }

    private func triggerClockworkTick() {
        guard currentAmbient == .clockwork, currentVolume > 0.01 else { return }
        let isTick = (clockworkStep % 2 == 0)
        clockworkStep += 1
        backend.playClockworkTick(isTick: isTick, volume: currentVolume)
    }

    private func scheduleSoothingNoiseLoop(for sound: ChronosAmbientSound) {
        guard currentVolume > 0.01 else { return }
        backend.playSoothingNoiseLoop(for: sound, volume: currentVolume)
    }
}

// MARK: - Pomodoro ViewModel
@Observable
@MainActor
final class PomodoroViewModel {
    // MARK: - Timer State
    private(set) var currentPhase: PomodoroPhase = .focus
    private(set) var remainingSeconds: Int = 25 * 60
    private(set) var isRunning: Bool = false
    private(set) var isPaused: Bool = false
    private(set) var completedFocusInCycle: Int = 0

    // MARK: - Data & Settings
    var settings: PomodoroSettings {
        didSet {
            saveSettings()
            if !isRunning && !isPaused {
                remainingSeconds = settings.durationSeconds(for: currentPhase)
            }
            ChronosSoundEngine.shared.updateAmbient(
                sound: settings.ambientSound,
                volumePercent: settings.ambientVolume
            )
        }
    }
    var tasks: [PomodoroTask] = [] {
        didSet { saveTasks() }
    }
    var selectedTaskID: UUID? {
        didSet { saveSelectedTaskID() }
    }
    private(set) var sessions: [PomodoroSession] = [] {
        didSet { saveSessions() }
    }

    // MARK: - Private Properties
    private var timerTask: Task<Void, Never>?
    private var targetEndDate: Date?
    private let userDefaults: UserDefaults

    private enum StorageKey {
        static let settings = "chronos.pomodoro.settings.v2"
        static let tasks = "chronos.pomodoro.tasks.v2"
        static let sessions = "chronos.pomodoro.sessions.v2"
        static let selectedTaskID = "chronos.pomodoro.selectedTaskID.v2"
    }

    // MARK: - Initialization
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults

        if let data = userDefaults.data(forKey: StorageKey.settings),
           let decoded = try? JSONDecoder().decode(PomodoroSettings.self, from: data) {
            self.settings = decoded
        } else {
            self.settings = PomodoroSettings()
        }

        if let data = userDefaults.data(forKey: StorageKey.tasks),
           let decoded = try? JSONDecoder().decode([PomodoroTask].self, from: data) {
            self.tasks = decoded
        } else {
            self.tasks = [
                PomodoroTask(title: "Tartarus Zindan Mimarisi İncelemesi", estimatedPomodoros: 3, completedPomodoros: 1),
                PomodoroTask(title: "Zaman Çarkları Animasyon Optimizasyonu", estimatedPomodoros: 2, completedPomodoros: 0),
                PomodoroTask(title: "Altın Kum Saati Shader & Efektleri", estimatedPomodoros: 2, completedPomodoros: 0)
            ]
        }

        if let data = userDefaults.data(forKey: StorageKey.sessions),
           let decoded = try? JSONDecoder().decode([PomodoroSession].self, from: data) {
            self.sessions = decoded
        } else {
            self.sessions = []
        }

        if let idString = userDefaults.string(forKey: StorageKey.selectedTaskID),
           let uuid = UUID(uuidString: idString) {
            self.selectedTaskID = uuid
        } else {
            self.selectedTaskID = self.tasks.first(where: { !$0.isCompleted })?.id
        }

        self.remainingSeconds = self.settings.durationSeconds(for: .focus)
    }

    // MARK: - Computed Properties
    var totalSecondsForCurrentPhase: Int {
        settings.durationSeconds(for: currentPhase)
    }

    /// Elapsed ratio (0.0 -> 1.0)
    var progress: Double {
        let total = Double(totalSecondsForCurrentPhase)
        guard total > 0 else { return 0 }
        let elapsed = total - Double(remainingSeconds)
        return min(1.0, max(0.0, elapsed / total))
    }

    /// Remaining ratio (1.0 -> 0.0) for the Chronos Hourglass sand level
    var remainingRatio: Double {
        1.0 - progress
    }

    /// Current 1-indexed round number (`DÖNGÜ X / Y`)
    var currentRoundNumber: Int {
        min(max(1, settings.sessionsBeforeLongBreak), completedFocusInCycle + 1)
    }

    var formattedTime: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var selectedTask: PomodoroTask? {
        guard let selectedTaskID else { return nil }
        return tasks.first(where: { $0.id == selectedTaskID })
    }

    var uncompletedTasksCount: Int {
        tasks.filter { !$0.isCompleted }.count
    }

    var todayFocusSessionsCount: Int {
        let calendar = Calendar.current
        return sessions.filter {
            $0.phase == .focus && calendar.isDateInToday($0.completedAt)
        }.count
    }

    var todayFocusMinutes: Int {
        let calendar = Calendar.current
        let totalSeconds = sessions
            .filter { $0.phase == .focus && calendar.isDateInToday($0.completedAt) }
            .reduce(0) { $0 + $1.durationSeconds }
        return max(0, totalSeconds / 60)
    }

    var totalFocusSessionsCount: Int {
        sessions.filter { $0.phase == .focus }.count
    }

    var totalFocusMinutes: Int {
        let totalSeconds = sessions
            .filter { $0.phase == .focus }
            .reduce(0) { $0 + $1.durationSeconds }
        return max(0, totalSeconds / 60)
    }

    var formattedTotalFocusTime: String {
        let mins = totalFocusMinutes
        if mins < 60 {
            return "\(mins) dk"
        }
        let hours = mins / 60
        let rem = mins % 60
        return rem > 0 ? "\(hours) sa \(rem) dk" : "\(hours) saat"
    }

    var streakDays: Int {
        let calendar = Calendar.current
        let focusDates = Set(
            sessions
                .filter { $0.phase == .focus }
                .map { calendar.startOfDay(for: $0.completedAt) }
        )
        guard !focusDates.isEmpty else { return 0 }

        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())
        if !focusDates.contains(checkDate) {
            if let yesterday = calendar.date(byAdding: .day, value: -1, to: checkDate),
               focusDates.contains(yesterday) {
                checkDate = yesterday
            } else {
                return 0
            }
        }

        while focusDates.contains(checkDate) {
            streak += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = prev
        }
        return streak
    }

    var last7DaysActivity: [ChronosDayActivity] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "EEE"

        let todayStart = calendar.startOfDay(for: Date())
        return (0..<7).map { offset in
            let dayOffset = -(6 - offset)
            let date = calendar.date(byAdding: .day, value: dayOffset, to: todayStart) ?? todayStart
            let daySessions = sessions.filter {
                $0.phase == .focus && calendar.isDate($0.completedAt, inSameDayAs: date)
            }
            let count = daySessions.count
            let mins = daySessions.reduce(0) { $0 + $1.durationSeconds } / 60
            return ChronosDayActivity(
                id: "\(offset)-\(date.timeIntervalSince1970)",
                dayLabel: formatter.string(from: date),
                sessions: count,
                minutes: mins,
                isToday: calendar.isDateInToday(date)
            )
        }
    }

    var dailyGoalProgress: Double {
        guard settings.dailyGoalSessions > 0 else { return 0 }
        return min(1.0, Double(todayFocusSessionsCount) / Double(settings.dailyGoalSessions))
    }

    // MARK: - Timer Controls
    func toggleTimer() {
        if isRunning {
            pauseTimer()
        } else {
            startTimer()
        }
    }

    func startTimer() {
        guard !isRunning else { return }
        if settings.notificationsEnabled {
            requestNotificationPermissionIfNeeded()
        }

        if remainingSeconds <= 0 {
            remainingSeconds = settings.durationSeconds(for: currentPhase)
        }

        isRunning = true
        isPaused = false
        let now = Date()
        targetEndDate = now.addingTimeInterval(TimeInterval(remainingSeconds))
        if settings.notificationsEnabled {
            schedulePhaseEndNotification(in: remainingSeconds)
        }
        triggerImpactHaptic(style: .medium)

        timerTask?.cancel()
        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(200))
                guard !Task.isCancelled, let self else { break }
                self.tick()
            }
        }
    }

    func pauseTimer() {
        guard isRunning else { return }
        if let targetEndDate {
            let diff = Int(ceil(targetEndDate.timeIntervalSinceNow))
            remainingSeconds = max(0, diff)
        }
        isRunning = false
        isPaused = true
        targetEndDate = nil
        timerTask?.cancel()
        timerTask = nil
        cancelScheduledNotifications()
        triggerImpactHaptic(style: .light)
    }

    func resetTimer() {
        pauseTimer()
        isPaused = false
        remainingSeconds = settings.durationSeconds(for: currentPhase)
        triggerImpactHaptic(style: .rigid)
    }

    func selectPhase(_ phase: PomodoroPhase) {
        pauseTimer()
        isPaused = false
        currentPhase = phase
        remainingSeconds = settings.durationSeconds(for: phase)
        if settings.soundEnabled {
            ChronosSoundEngine.shared.playSwitchTone(isModeSwitch: true)
        }
        triggerSelectionHaptic()
    }

    func skipToNextPhase() {
        pauseTimer()
        isPaused = false
        advancePhase(recordSession: false)
        if settings.soundEnabled {
            ChronosSoundEngine.shared.playSwitchTone(isModeSwitch: true)
        }
        triggerImpactHaptic(style: .soft)
    }

    func selectAmbientSound(_ sound: ChronosAmbientSound) {
        settings.ambientSound = sound
        if settings.soundEnabled {
            ChronosSoundEngine.shared.playSwitchTone(isModeSwitch: false)
        }
        ChronosSoundEngine.shared.updateAmbient(
            sound: sound,
            volumePercent: settings.ambientVolume
        )
        triggerSelectionHaptic()
    }

    func updateAmbientVolume(_ volume: Int) {
        settings.ambientVolume = max(5, min(100, volume))
        ChronosSoundEngine.shared.updateAmbient(
            sound: settings.ambientSound,
            volumePercent: settings.ambientVolume
        )
    }

    func toggleQuickTheme() {
        settings.appTheme = (settings.appTheme == .chronos) ? .sunset : .chronos
        triggerSelectionHaptic()
    }

    func testAlertSound() {
        ChronosSoundEngine.shared.playBell(
            theme: settings.soundTheme,
            volumePercent: settings.soundVolume
        )
        triggerSelectionHaptic()
    }

    /// Synchronizes timer state when returning from background or on each tick
    func syncWithCurrentTime() {
        guard isRunning else { return }
        tick()
    }

    /// Advances the timer and completes current phase immediately
    func completeCurrentPhaseNow() {
        pauseTimer()
        isPaused = false
        handlePhaseCompletion()
    }

    // MARK: - Internal Tick & Phase Transition
    private func tick() {
        guard isRunning, let targetEndDate else { return }
        let remaining = Int(ceil(targetEndDate.timeIntervalSinceNow))
        if remaining <= 0 {
            remainingSeconds = 0
            isRunning = false
            isPaused = false
            self.targetEndDate = nil
            timerTask?.cancel()
            timerTask = nil
            handlePhaseCompletion()
        } else if remaining != remainingSeconds {
            remainingSeconds = remaining
        }
    }

    private func handlePhaseCompletion() {
        playCompletionFeedback()
        advancePhase(recordSession: true)
    }

    private func advancePhase(recordSession: Bool) {
        let finishedPhase = currentPhase
        let finishedDuration = settings.durationSeconds(for: finishedPhase)

        if recordSession {
            let record = PomodoroSession(
                phase: finishedPhase,
                durationSeconds: finishedDuration,
                completedAt: Date(),
                taskTitle: selectedTask?.title
            )
            sessions.insert(record, at: 0)

            if finishedPhase == .focus, let selectedTaskID,
               let index = tasks.firstIndex(where: { $0.id == selectedTaskID }) {
                tasks[index].completedPomodoros += 1
                if tasks[index].completedPomodoros >= tasks[index].estimatedPomodoros {
                    tasks[index].isCompleted = true
                }
            }
        }

        // Determine next phase
        switch finishedPhase {
        case .focus:
            completedFocusInCycle += 1
            if completedFocusInCycle >= settings.sessionsBeforeLongBreak {
                currentPhase = .longBreak
                completedFocusInCycle = 0
            } else {
                currentPhase = .shortBreak
            }
        case .shortBreak, .longBreak:
            currentPhase = .focus
        }

        remainingSeconds = settings.durationSeconds(for: currentPhase)

        // Auto-start if enabled
        let shouldAutoStart: Bool
        switch currentPhase {
        case .focus:
            shouldAutoStart = recordSession && settings.autoStartFocus
        case .shortBreak, .longBreak:
            shouldAutoStart = recordSession && settings.autoStartBreaks
        }

        if shouldAutoStart {
            startTimer()
        }
    }

    // MARK: - Task Management
    func addTask(title: String, estimatedPomodoros: Int) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let newTask = PomodoroTask(
            title: trimmed,
            estimatedPomodoros: max(1, estimatedPomodoros)
        )
        tasks.insert(newTask, at: 0)
        if selectedTaskID == nil {
            selectedTaskID = newTask.id
        }
        triggerImpactHaptic(style: .light)
    }

    func toggleTaskCompletion(_ task: PomodoroTask) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index].isCompleted.toggle()
        if tasks[index].isCompleted && selectedTaskID == task.id {
            selectedTaskID = tasks.first(where: { !$0.isCompleted })?.id
        } else if !tasks[index].isCompleted && selectedTaskID == nil {
            selectedTaskID = task.id
        }
        triggerSelectionHaptic()
    }

    func deleteTask(_ task: PomodoroTask) {
        tasks.removeAll { $0.id == task.id }
        if selectedTaskID == task.id {
            selectedTaskID = tasks.first(where: { !$0.isCompleted })?.id
        }
    }

    func selectTask(_ task: PomodoroTask?) {
        if let task {
            selectedTaskID = (selectedTaskID == task.id) ? nil : task.id
        } else {
            selectedTaskID = nil
        }
        triggerSelectionHaptic()
    }

    func clearHistory() {
        sessions.removeAll()
        completedFocusInCycle = 0
    }

    // MARK: - Persistence
    private func saveSettings() {
        if let data = try? JSONEncoder().encode(settings) {
            userDefaults.set(data, forKey: StorageKey.settings)
        }
    }

    private func saveTasks() {
        if let data = try? JSONEncoder().encode(tasks) {
            userDefaults.set(data, forKey: StorageKey.tasks)
        }
    }

    private func saveSessions() {
        if let data = try? JSONEncoder().encode(sessions) {
            userDefaults.set(data, forKey: StorageKey.sessions)
        }
    }

    private func saveSelectedTaskID() {
        userDefaults.set(selectedTaskID?.uuidString, forKey: StorageKey.selectedTaskID)
    }

    // MARK: - Haptics, Sound & Local Notifications
    private func triggerImpactHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard settings.hapticsEnabled else { return }
        #if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
        #endif
    }

    private func triggerSelectionHaptic() {
        guard settings.hapticsEnabled else { return }
        #if canImport(UIKit)
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
        #endif
    }

    private func playCompletionFeedback() {
        if settings.hapticsEnabled {
            #if canImport(UIKit)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            #endif
        }
        if settings.soundEnabled {
            ChronosSoundEngine.shared.playBell(
                theme: settings.soundTheme,
                volumePercent: settings.soundVolume
            )
        }
    }

    private func requestNotificationPermissionIfNeeded() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    private func schedulePhaseEndNotification(in seconds: Int) {
        guard seconds > 0 else { return }
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        let content = UNMutableNotificationContent()
        switch currentPhase {
        case .focus:
            content.title = "Odaklanma Seansı Bitti! ⏳"
            content.body = "Tebrikler! Şimdi zihnini dinlendirmek için güzel bir mola ver."
        case .shortBreak, .longBreak:
            content.title = "Mola Bitti! ⚡️"
            content.body = "Molan sona erdi. Yeni bir Chronos seansına hazır mısın?"
        }
        if settings.soundEnabled {
            content.sound = .default
        }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(seconds), repeats: false)
        let request = UNNotificationRequest(identifier: "chronos.pomodoro.phase.end", content: content, trigger: trigger)
        center.add(request)
    }

    private func cancelScheduledNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
