//
//  PomodoroModels.swift
//  Pomodoro
//
//  Created by Onur Arda on 18.10.2026.
//

import SwiftUI
import Foundation

// MARK: - Pomodoro Phase (Chronos • Titan of Time)
enum PomodoroPhase: String, CaseIterable, Codable, Identifiable {
    case focus = "focus"
    case shortBreak = "shortBreak"
    case longBreak = "longBreak"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .focus:
            return "Çalışma"
        case .shortBreak:
            return "Kısa Mola"
        case .longBreak:
            return "Uzun Mola"
        }
    }

    var shortTitle: String {
        switch self {
        case .focus:
            return "Çalışma"
        case .shortBreak:
            return "Mola"
        case .longBreak:
            return "Uzun Mola"
        }
    }

    var subtitle: String {
        switch self {
        case .focus:
            return "Çalışma Zamanı"
        case .shortBreak:
            return "Mola Zamanı"
        case .longBreak:
            return "Uzun Mola Zamanı"
        }
    }

    func statusText(isRunning: Bool, isPaused: Bool) -> String {
        if isRunning {
            return subtitle
        }
        if isPaused {
            return "Zaman Duraklatıldı"
        }
        return title
    }

    var symbolName: String {
        switch self {
        case .focus:
            return "sparkles"
        case .shortBreak:
            return "shield.lefthalf.filled"
        case .longBreak:
            return "moon.stars.fill"
        }
    }

    var primaryColor: Color {
        switch self {
        case .focus:
            return Color(red: 0.96, green: 0.62, blue: 0.04) // Chronos Gold #f59e0b
        case .shortBreak:
            return Color(red: 0.06, green: 0.73, blue: 0.51) // Underworld Jade #10b981
        case .longBreak:
            return Color(red: 0.22, green: 0.74, blue: 0.97) // Aether Sky #38bdf8
        }
    }

    var secondaryColor: Color {
        switch self {
        case .focus:
            return Color(red: 0.98, green: 0.75, blue: 0.14) // Bright Gold #fbbf24
        case .shortBreak:
            return Color(red: 0.08, green: 0.58, blue: 0.41) // Deep Emerald #059669
        case .longBreak:
            return Color(red: 0.31, green: 0.27, blue: 0.90) // Cosmic Indigo #4f46e5
        }
    }

    var sandTopColor: Color {
        switch self {
        case .focus:
            return Color(red: 0.996, green: 0.941, blue: 0.541) // #fef08a
        case .shortBreak:
            return Color(red: 0.431, green: 0.906, blue: 0.718) // #6ee7b7
        case .longBreak:
            return Color(red: 0.490, green: 0.827, blue: 0.988) // #7dd3fc
        }
    }

    var sandMidColor: Color {
        switch self {
        case .focus:
            return Color(red: 0.961, green: 0.620, blue: 0.043) // #f59e0b
        case .shortBreak:
            return Color(red: 0.063, green: 0.725, blue: 0.506) // #10b981
        case .longBreak:
            return Color(red: 0.055, green: 0.647, blue: 0.914) // #0ea5e9
        }
    }

    var sandDarkColor: Color {
        switch self {
        case .focus:
            return Color(red: 0.706, green: 0.325, blue: 0.035) // #b45309
        case .shortBreak:
            return Color(red: 0.016, green: 0.471, blue: 0.341) // #047857
        case .longBreak:
            return Color(red: 0.012, green: 0.412, blue: 0.631) // #0369a1
        }
    }
}

// MARK: - Chronos Sound Theme
enum ChronosSoundTheme: String, CaseIterable, Codable, Identifiable {
    case chronosBell = "chronos-bell"
    case zenBell = "zen-bell"
    case singingBowl = "singing-bowl"
    case digital = "digital"
    case marimba = "marimba"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .chronosBell:
            return "Titan Çanı (Chronos Zili)"
        case .zenBell:
            return "Zen Çanı (Gong)"
        case .singingBowl:
            return "Tibet Kasesi"
        case .digital:
            return "Dijital Çan"
        case .marimba:
            return "Akustik Marimba"
        }
    }
}

// MARK: - Ambient Sound Type
enum ChronosAmbientSound: String, CaseIterable, Codable, Identifiable {
    case none = "none"
    case clockwork = "clockwork"
    case rain = "rain"
    case stream = "white-noise"
    case cafe = "cafe"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .none:
            return "Kapalı"
        case .clockwork:
            return "Zaman Çarkları"
        case .rain:
            return "Yağmur"
        case .stream:
            return "Akarsu"
        case .cafe:
            return "Kafe"
        }
    }

    var symbolName: String {
        switch self {
        case .none:
            return "speaker.slash.fill"
        case .clockwork:
            return "gearshape.2.fill"
        case .rain:
            return "cloud.rain.fill"
        case .stream:
            return "water.waves"
        case .cafe:
            return "cup.and.saucer.fill"
        }
    }
}

// MARK: - Chronos App Theme
enum ChronosAppTheme: String, CaseIterable, Codable, Identifiable {
    case chronos = "chronos"
    case dark = "dark"
    case sunset = "sunset"
    case forest = "forest"
    case light = "light"
    case system = "system"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .chronos:
            return "CHRONOS • Zamanın Titanı"
        case .dark:
            return "Obsidyen"
        case .sunset:
            return "Kızıl Akşam"
        case .forest:
            return "Zümrüt Doğa"
        case .light:
            return "Zen Kağıt"
        case .system:
            return "Sistem"
        }
    }

    var subtitle: String {
        switch self {
        case .chronos:
            return "Dönen Çarklar, Antik Kum Saati & Hades II"
        case .dark:
            return "Karanlık"
        case .sunset:
            return "Alacakaranlık"
        case .forest:
            return "Matcha & Orman"
        case .light:
            return "Aydınlık"
        case .system:
            return "Otomatik"
        }
    }

    var symbolName: String {
        switch self {
        case .chronos:
            return "hourglass"
        case .dark:
            return "moon.fill"
        case .sunset:
            return "sunset.fill"
        case .forest:
            return "tree.fill"
        case .light:
            return "sun.max.fill"
        case .system:
            return "iphone"
        }
    }

    var backgroundColors: [Color] {
        switch self {
        case .chronos:
            return [
                Color(red: 0.024, green: 0.035, blue: 0.051), // #06090d
                Color(red: 0.043, green: 0.067, blue: 0.094), // #0b1118
                Color(red: 0.016, green: 0.024, blue: 0.035)  // #040609
            ]
        case .dark:
            return [
                Color(red: 0.035, green: 0.035, blue: 0.043),
                Color(red: 0.07, green: 0.07, blue: 0.09),
                Color(red: 0.02, green: 0.02, blue: 0.03)
            ]
        case .sunset:
            return [
                Color(red: 0.09, green: 0.04, blue: 0.14),
                Color(red: 0.16, green: 0.06, blue: 0.18),
                Color(red: 0.05, green: 0.02, blue: 0.09)
            ]
        case .forest:
            return [
                Color(red: 0.02, green: 0.09, blue: 0.06),
                Color(red: 0.04, green: 0.14, blue: 0.09),
                Color(red: 0.01, green: 0.05, blue: 0.04)
            ]
        case .light:
            return [
                Color(red: 0.11, green: 0.09, blue: 0.06),
                Color(red: 0.16, green: 0.13, blue: 0.08),
                Color(red: 0.08, green: 0.06, blue: 0.04)
            ]
        case .system:
            return [
                Color(red: 0.024, green: 0.035, blue: 0.051),
                Color(red: 0.043, green: 0.067, blue: 0.094),
                Color(red: 0.016, green: 0.024, blue: 0.035)
            ]
        }
    }
}

// MARK: - Task Filter
enum ChronosTaskFilter: String, CaseIterable, Identifiable {
    case all = "all"
    case active = "active"
    case completed = "completed"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all:
            return "Tümü"
        case .active:
            return "Aktif"
        case .completed:
            return "Tamamlanan"
        }
    }
}

// MARK: - Pomodoro Task
struct PomodoroTask: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var estimatedPomodoros: Int = 4
    var completedPomodoros: Int = 0
    var isCompleted: Bool = false
    var createdAt: Date = Date()

    var progress: Double {
        guard estimatedPomodoros > 0 else { return 0 }
        return min(1.0, Double(completedPomodoros) / Double(estimatedPomodoros))
    }
}

// MARK: - Completed Session Record
struct PomodoroSession: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var phase: PomodoroPhase
    var durationSeconds: Int
    var completedAt: Date = Date()
    var taskTitle: String?
}

// MARK: - Daily Activity Point (7-Day Chart)
struct ChronosDayActivity: Identifiable, Equatable {
    let id: String
    let dayLabel: String
    let sessions: Int
    let minutes: Int
    let isToday: Bool
}

// MARK: - User Settings
struct PomodoroSettings: Codable, Equatable {
    var focusMinutes: Int = 25
    var shortBreakMinutes: Int = 5
    var longBreakMinutes: Int = 15
    var sessionsBeforeLongBreak: Int = 4
    var dailyGoalSessions: Int = 8
    var autoStartBreaks: Bool = false
    var autoStartFocus: Bool = false
    var soundEnabled: Bool = true
    var soundVolume: Int = 80
    var soundTheme: ChronosSoundTheme = .chronosBell
    var notificationsEnabled: Bool = true
    var hapticsEnabled: Bool = true
    var ambientSound: ChronosAmbientSound = .none
    var ambientVolume: Int = 50
    var appTheme: ChronosAppTheme = .chronos

    func durationSeconds(for phase: PomodoroPhase) -> Int {
        switch phase {
        case .focus:
            return max(1, focusMinutes) * 60
        case .shortBreak:
            return max(1, shortBreakMinutes) * 60
        case .longBreak:
            return max(1, longBreakMinutes) * 60
        }
    }
}

// MARK: - Chronos Palette Helpers
enum ChronosPalette {
    static let goldBright = Color(red: 0.996, green: 0.941, blue: 0.541)   // #fef08a
    static let goldPrimary = Color(red: 0.984, green: 0.749, blue: 0.141)  // #fbbf24
    static let goldAmber = Color(red: 0.961, green: 0.620, blue: 0.043)    // #f59e0b
    static let goldBronze = Color(red: 0.851, green: 0.467, blue: 0.024)   // #d97706
    static let goldDeep = Color(red: 0.471, green: 0.208, blue: 0.059)     // #78350f
    static let jadeBright = Color(red: 0.204, green: 0.827, blue: 0.600)   // #34d399
    static let jadePrimary = Color(red: 0.063, green: 0.725, blue: 0.506)  // #10b981
    static let obsidianDark = Color(red: 0.024, green: 0.035, blue: 0.051) // #06090d
    static let obsidianCard = Color(red: 0.039, green: 0.055, blue: 0.078) // #0a0e14
    static let obsidianAltar = Color(red: 0.043, green: 0.071, blue: 0.106)// #0b121b
}
