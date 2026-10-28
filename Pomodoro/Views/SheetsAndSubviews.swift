//
//  SheetsAndSubviews.swift
//  Pomodoro
//
//  Created by Onur Arda on 18.10.2026.
//

import SwiftUI

// MARK: - Tasks Sheet View (Zamanın Görevleri - Port of TaskModal.tsx)
struct TasksSheetView: View {
    @Bindable var viewModel: PomodoroViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var filter: ChronosTaskFilter = .all
    @State private var isAddingTask: Bool = false
    @State private var newTaskTitle: String = ""
    @State private var estimatedCount: Int = 2
    @FocusState private var isInputFocused: Bool

    private var filteredTasks: [PomodoroTask] {
        switch filter {
        case .all:
            return viewModel.tasks
        case .active:
            return viewModel.tasks.filter { !$0.isCompleted }
        case .completed:
            return viewModel.tasks.filter { $0.isCompleted }
        }
    }

    var body: some View {
        ZStack {
            ChronosPalette.obsidianCard.ignoresSafeArea()

            VStack(spacing: 0) {
                // Sheet Top Header Bar
                HStack(spacing: 8) {
                    Image(systemName: "hourglass")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(ChronosPalette.goldPrimary)

                    Text("Zamanın Görevleri")
                        .font(.system(size: 16, weight: .bold, design: .serif))
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                        .foregroundStyle(ChronosPalette.goldBright)

                    Text("\(viewModel.uncompletedTasksCount) aktif")
                        .font(.system(size: 10, weight: .bold, design: .serif))
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        .foregroundStyle(ChronosPalette.goldBright)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(ChronosPalette.goldAmber.opacity(0.22))
                                .overlay(
                                    Capsule()
                                        .strokeBorder(ChronosPalette.goldAmber.opacity(0.4), lineWidth: 1)
                                )
                        )

                    Spacer(minLength: 8)

                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(ChronosPalette.goldPrimary.opacity(0.85))
                            .frame(width: 30, height: 30)
                            .background(
                                RoundedRectangle(cornerRadius: 9, style: .continuous)
                                    .fill(ChronosPalette.goldAmber.opacity(0.14))
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 18)
                .padding(.top, 18)
                .padding(.bottom, 12)
                .background(ChronosPalette.obsidianCard)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(ChronosPalette.goldAmber.opacity(0.2))
                        .frame(height: 1)
                }

                // Filter Bar
                HStack(spacing: 8) {
                    Text("Filtrele:")
                        .font(.system(size: 12, weight: .medium, design: .serif))
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        .foregroundStyle(ChronosPalette.goldPrimary.opacity(0.75))

                    Spacer(minLength: 4)

                    HStack(spacing: 4) {
                        ForEach(ChronosTaskFilter.allCases) { item in
                            let isSelected = filter == item
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    filter = item
                                }
                            } label: {
                                Text(item.title)
                                    .font(.system(size: 12, weight: isSelected ? .bold : .medium, design: .serif))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.85)
                                    .fixedSize(horizontal: true, vertical: false)
                                    .foregroundStyle(
                                        isSelected
                                            ? ChronosPalette.goldBright
                                            : ChronosPalette.goldPrimary.opacity(0.6)
                                    )
                                    .padding(.horizontal, 11)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 9, style: .continuous)
                                            .fill(isSelected ? ChronosPalette.goldAmber.opacity(0.28) : Color.clear)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 9, style: .continuous)
                                                    .strokeBorder(
                                                        isSelected ? ChronosPalette.goldPrimary.opacity(0.5) : Color.clear,
                                                        lineWidth: 1
                                                    )
                                            )
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(3)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.black.opacity(0.55))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .strokeBorder(ChronosPalette.goldAmber.opacity(0.25), lineWidth: 1)
                            )
                    )
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(Color.black.opacity(0.35))
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(ChronosPalette.goldAmber.opacity(0.2))
                        .frame(height: 1)
                }

                // Task List
                ScrollView {
                    VStack(spacing: 10) {
                        if filteredTasks.isEmpty {
                            VStack(spacing: 10) {
                                Image(systemName: "hourglass")
                                    .font(.system(size: 28))
                                    .foregroundStyle(ChronosPalette.goldPrimary.opacity(0.5))
                                Text(emptyStateMessage)
                                    .font(.system(size: 13, weight: .medium, design: .serif))
                                    .foregroundStyle(ChronosPalette.goldPrimary.opacity(0.65))
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.vertical, 44)
                            .padding(.horizontal, 24)
                        } else {
                            ForEach(filteredTasks) { task in
                                taskRow(for: task)
                            }
                        }
                    }
                    .padding(16)
                }

                // Footer Add Task Area
                VStack(spacing: 12) {
                    if !isAddingTask {
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                isAddingTask = true
                                isInputFocused = true
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "plus")
                                    .font(.system(size: 14, weight: .bold))
                                Text("Yeni Görev Belirle")
                                    .font(.system(size: 14, weight: .semibold, design: .serif))
                                    .lineLimit(1)
                            }
                            .foregroundStyle(ChronosPalette.goldBright)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .strokeBorder(
                                        ChronosPalette.goldAmber.opacity(0.45),
                                        style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])
                                    )
                                    .background(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .fill(Color.black.opacity(0.35))
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    } else {
                        VStack(spacing: 12) {
                            TextField("Görev adı...", text: $newTaskTitle)
                                .focused($isInputFocused)
                                .font(.system(size: 14, design: .serif))
                                .foregroundStyle(ChronosPalette.goldBright)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(Color.black.opacity(0.65))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .strokeBorder(ChronosPalette.goldAmber.opacity(0.45), lineWidth: 1)
                                        )
                                )
                                .submitLabel(.done)
                                .onSubmit(saveNewTask)

                            HStack(spacing: 8) {
                                Text("Tahmini Süre (Kum Saati):")
                                    .font(.system(size: 12, weight: .medium, design: .serif))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                    .foregroundStyle(ChronosPalette.goldPrimary.opacity(0.85))

                                Spacer(minLength: 4)

                                HStack(spacing: 8) {
                                    Button {
                                        estimatedCount = max(1, estimatedCount - 1)
                                    } label: {
                                        Text("-")
                                            .font(.system(size: 15, weight: .bold, design: .monospaced))
                                            .foregroundStyle(ChronosPalette.goldBright)
                                            .frame(width: 28, height: 28)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                    .fill(Color.black.opacity(0.6))
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                            .strokeBorder(ChronosPalette.goldAmber.opacity(0.35), lineWidth: 1)
                                                    )
                                            )
                                    }
                                    .buttonStyle(.plain)

                                    Text("⏳ \(estimatedCount)")
                                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                                        .lineLimit(1)
                                        .fixedSize(horizontal: true, vertical: false)
                                        .frame(minWidth: 38)
                                        .foregroundStyle(ChronosPalette.goldBright)

                                    Button {
                                        estimatedCount = min(10, estimatedCount + 1)
                                    } label: {
                                        Text("+")
                                            .font(.system(size: 15, weight: .bold, design: .monospaced))
                                            .foregroundStyle(ChronosPalette.goldBright)
                                            .frame(width: 28, height: 28)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                    .fill(Color.black.opacity(0.6))
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                            .strokeBorder(ChronosPalette.goldAmber.opacity(0.35), lineWidth: 1)
                                                    )
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }

                            HStack(spacing: 10) {
                                Spacer()
                                Button("Vazgeç") {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        isAddingTask = false
                                        newTaskTitle = ""
                                    }
                                }
                                .font(.system(size: 12, weight: .medium, design: .serif))
                                .foregroundStyle(ChronosPalette.goldPrimary.opacity(0.7))

                                Button(action: saveNewTask) {
                                    Text("Mühürle & Kaydet")
                                        .font(.system(size: 12, weight: .bold, design: .serif))
                                        .lineLimit(1)
                                        .foregroundStyle(.black)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                .fill(
                                                    LinearGradient(
                                                        colors: [ChronosPalette.goldBronze, ChronosPalette.goldPrimary],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                )
                                        )
                                }
                                .disabled(newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                                .opacity(newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)
                            }
                        }
                    }
                }
                .padding(16)
                .background(Color.black.opacity(0.45))
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(ChronosPalette.goldAmber.opacity(0.2))
                        .frame(height: 1)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var emptyStateMessage: String {
        switch filter {
        case .completed:
            return "Henüz mühürlenmiş görev yok."
        case .active:
            return "Tüm görevler mühürlendi, zaman seninle!"
        case .all:
            return "Listen henüz boş. Aşağıdan yeni bir irade hedefi ekleyebilirsin."
        }
    }

    private func taskRow(for task: PomodoroTask) -> some View {
        let isActive = viewModel.selectedTaskID == task.id
        return HStack(spacing: 10) {
            // Checkbox
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.78)) {
                    viewModel.toggleTaskCompletion(task)
                }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(task.isCompleted ? ChronosPalette.jadePrimary : Color.clear)
                        .frame(width: 22, height: 22)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .strokeBorder(
                                    task.isCompleted ? ChronosPalette.jadeBright : ChronosPalette.goldAmber.opacity(0.45),
                                    lineWidth: 1.5
                                )
                        )

                    if task.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .black))
                            .foregroundStyle(.black)
                    }
                }
            }
            .buttonStyle(.plain)

            // Title & Hourglass Progress
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.system(size: 13.5, weight: .medium, design: .serif))
                    .lineLimit(2)
                    .minimumScaleFactor(0.88)
                    .strikethrough(task.isCompleted, color: ChronosPalette.goldPrimary.opacity(0.4))
                    .foregroundStyle(
                        task.isCompleted
                            ? ChronosPalette.goldPrimary.opacity(0.4)
                            : ChronosPalette.goldBright
                    )

                HStack(spacing: 8) {
                    Text("⏳ \(task.completedPomodoros) / \(task.estimatedPomodoros)")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        .foregroundStyle(ChronosPalette.goldPrimary.opacity(0.8))

                    if task.completedPomodoros >= task.estimatedPomodoros {
                        Text("Zafer kazanıldı")
                            .font(.system(size: 10, weight: .semibold, design: .serif))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                            .foregroundStyle(ChronosPalette.jadeBright)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Focus / Active button
            if !task.isCompleted {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        viewModel.selectTask(task)
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "scope")
                            .font(.system(size: 11, weight: .bold))
                        Text(isActive ? "Aktif" : "Odaklan")
                            .font(.system(size: 11, weight: .bold, design: .serif))
                            .lineLimit(1)
                    }
                    .fixedSize(horizontal: true, vertical: false)
                    .foregroundStyle(isActive ? Color.black : ChronosPalette.goldBright)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 9, style: .continuous)
                            .fill(isActive ? ChronosPalette.goldAmber : Color.black.opacity(0.6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 9, style: .continuous)
                                    .strokeBorder(ChronosPalette.goldAmber.opacity(0.4), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(.plain)
            }

            // Delete button
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.deleteTask(task)
                }
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 13))
                    .foregroundStyle(ChronosPalette.goldPrimary.opacity(0.55))
                    .padding(6)
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(isActive ? ChronosPalette.goldAmber.opacity(0.15) : Color.black.opacity(0.42))
                .overlay(
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .strokeBorder(
                            isActive ? ChronosPalette.goldPrimary.opacity(0.75) : ChronosPalette.goldAmber.opacity(0.22),
                            lineWidth: 1
                        )
                )
        )
    }

    private func saveNewTask() {
        let trimmed = newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
            viewModel.addTask(title: trimmed, estimatedPomodoros: estimatedCount)
            newTaskTitle = ""
            estimatedCount = 2
            isAddingTask = false
            isInputFocused = false
        }
    }
}

// MARK: - Statistics Sheet View (Zamanın Kayıtları - Port of StatsModal.tsx)
struct StatsSheetView: View {
    @Bindable var viewModel: PomodoroViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        let weekData = viewModel.last7DaysActivity
        let maxSessions = max(1, weekData.map(\.sessions).max() ?? 1)

        ZStack {
            ChronosPalette.obsidianCard.ignoresSafeArea()

            VStack(spacing: 0) {
                // Sheet Top Header Bar
                HStack(spacing: 8) {
                    Image(systemName: "hourglass")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(ChronosPalette.goldPrimary)

                    Text("Zamanın Kayıtları (İstatistik)")
                        .font(.system(size: 15.5, weight: .bold, design: .serif))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .foregroundStyle(ChronosPalette.goldBright)

                    Spacer(minLength: 8)

                    Button("Kapat") {
                        dismiss()
                    }
                    .font(.system(size: 13, weight: .bold, design: .serif))
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                    .foregroundStyle(ChronosPalette.goldBright)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(ChronosPalette.goldAmber.opacity(0.14))
                    )
                }
                .padding(.horizontal, 18)
                .padding(.top, 18)
                .padding(.bottom, 12)
                .background(ChronosPalette.obsidianCard)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(ChronosPalette.goldAmber.opacity(0.2))
                        .frame(height: 1)
                }

                ScrollView {
                    VStack(spacing: 18) {
                        // 4 Metric Cards (Toplam Süre, Seanslar, Seri, Bugün)
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ChronosStatCard(
                                title: "Toplam Süre",
                                value: viewModel.formattedTotalFocusTime,
                                subtitle: nil,
                                icon: "clock.fill",
                                iconColor: ChronosPalette.goldPrimary
                            )

                            ChronosStatCard(
                                title: "Seanslar",
                                value: "\(viewModel.totalFocusSessionsCount)",
                                subtitle: "adet",
                                icon: "trophy.fill",
                                iconColor: ChronosPalette.goldPrimary
                            )

                            ChronosStatCard(
                                title: "Seri",
                                value: "\(viewModel.streakDays)",
                                subtitle: "gün",
                                icon: "flame.fill",
                                iconColor: .orange
                            )

                            ChronosStatCard(
                                title: "Bugün",
                                value: "\(viewModel.todayFocusSessionsCount)",
                                subtitle: "seans",
                                icon: "checkmark.circle.fill",
                                iconColor: ChronosPalette.jadeBright
                            )
                        }

                        // 7-Day Activity Chart ("Son 7 Günlük Zaman Akışı")
                        VStack(alignment: .leading, spacing: 14) {
                            HStack(spacing: 8) {
                                Text("Son 7 Günlük Zaman Akışı")
                                    .font(.system(size: 13, weight: .semibold, design: .serif))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                    .foregroundStyle(ChronosPalette.goldPrimary.opacity(0.9))
                                Spacer(minLength: 4)
                                Text("Bugün: \(viewModel.todayFocusMinutes) dk")
                                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                                    .lineLimit(1)
                                    .fixedSize(horizontal: true, vertical: false)
                                    .foregroundStyle(ChronosPalette.goldBright.opacity(0.7))
                            }

                            HStack(alignment: .bottom, spacing: 8) {
                                ForEach(weekData) { day in
                                    let ratio = CGFloat(day.sessions) / CGFloat(maxSessions)
                                    let barHeight = max(8, ratio * 96)

                                    VStack(spacing: 6) {
                                        Text(day.sessions > 0 ? "\(day.sessions)" : "")
                                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.75)
                                            .foregroundStyle(ChronosPalette.goldBright.opacity(0.8))
                                            .frame(height: 14)

                                        Spacer(minLength: 0)

                                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                                            .fill(
                                                day.isToday
                                                    ? LinearGradient(
                                                        colors: [ChronosPalette.goldPrimary, ChronosPalette.goldBronze],
                                                        startPoint: .top,
                                                        endPoint: .bottom
                                                    )
                                                    : day.sessions > 0
                                                    ? LinearGradient(
                                                        colors: [ChronosPalette.goldBronze, ChronosPalette.goldDeep],
                                                        startPoint: .top,
                                                        endPoint: .bottom
                                                    )
                                                    : LinearGradient(
                                                        colors: [ChronosPalette.goldBronze.opacity(0.15), ChronosPalette.goldDeep.opacity(0.1)],
                                                        startPoint: .top,
                                                        endPoint: .bottom
                                                    )
                                            )
                                            .frame(maxWidth: 32)
                                            .frame(height: barHeight)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                                    .strokeBorder(ChronosPalette.goldPrimary.opacity(0.4), lineWidth: 1)
                                            )

                                        Text(day.dayLabel)
                                            .font(.system(size: 10.5, weight: day.isToday ? .bold : .regular, design: .serif))
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.75)
                                            .foregroundStyle(
                                                day.isToday
                                                    ? ChronosPalette.goldBright
                                                    : ChronosPalette.goldPrimary.opacity(0.6)
                                            )
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 138)
                                }
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color.black.opacity(0.45))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .strokeBorder(ChronosPalette.goldAmber.opacity(0.22), lineWidth: 1)
                                )
                        )

                        // Recent Sessions History
                        if !viewModel.sessions.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("Mühürlenen Seanslar")
                                        .font(.system(size: 13, weight: .semibold, design: .serif))
                                        .lineLimit(1)
                                        .foregroundStyle(ChronosPalette.goldPrimary.opacity(0.9))
                                    Spacer()
                                    Button("Sıfırla", role: .destructive) {
                                        withAnimation {
                                            viewModel.clearHistory()
                                        }
                                    }
                                    .font(.system(size: 11, weight: .semibold, design: .serif))
                                    .lineLimit(1)
                                }

                                ForEach(viewModel.sessions.prefix(8)) { session in
                                    HStack(spacing: 10) {
                                        Image(systemName: session.phase.symbolName)
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundStyle(session.phase.primaryColor)
                                            .frame(width: 30, height: 30)
                                            .background(
                                                Circle()
                                                    .fill(session.phase.primaryColor.opacity(0.15))
                                            )

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(session.taskTitle ?? session.phase.title)
                                                .font(.system(size: 13, weight: .medium, design: .serif))
                                                .lineLimit(1)
                                                .truncationMode(.tail)
                                                .foregroundStyle(ChronosPalette.goldBright)
                                            Text(session.completedAt.formatted(date: .abbreviated, time: .shortened))
                                                .font(.system(size: 10, design: .monospaced))
                                                .lineLimit(1)
                                                .foregroundStyle(ChronosPalette.goldPrimary.opacity(0.6))
                                        }

                                        Spacer(minLength: 4)

                                        Text("\(max(1, session.durationSeconds / 60)) dk")
                                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                                            .lineLimit(1)
                                            .fixedSize(horizontal: true, vertical: false)
                                            .foregroundStyle(ChronosPalette.goldPrimary)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(Color.black.opacity(0.45))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                                            .strokeBorder(ChronosPalette.goldAmber.opacity(0.22), lineWidth: 1)
                                    )
                            )
                        }
                    }
                    .padding(16)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

private struct ChronosStatCard: View {
    let title: String
    let value: String
    let subtitle: String?
    let icon: String
    let iconColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(iconColor)
                Text(title)
                    .font(.system(size: 12, weight: .medium, design: .serif))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .foregroundStyle(ChronosPalette.goldPrimary.opacity(0.8))
            }

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 19, weight: .bold, design: .serif))
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)
                    .foregroundStyle(ChronosPalette.goldBright)
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 11, weight: .regular, design: .serif))
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        .foregroundStyle(ChronosPalette.goldPrimary.opacity(0.65))
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.black.opacity(0.45))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(ChronosPalette.goldAmber.opacity(0.22), lineWidth: 1)
                )
        )
    }
}

// MARK: - Settings Sheet View (Ayarlar - Port of SettingsModal.tsx)
struct SettingsSheetView: View {
    @Bindable var viewModel: PomodoroViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            ChronosPalette.obsidianCard.ignoresSafeArea()

            VStack(spacing: 0) {
                // Sheet Top Header Bar
                HStack(spacing: 8) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(ChronosPalette.goldPrimary)

                    Text("Ayarlar")
                        .font(.system(size: 16, weight: .bold, design: .serif))
                        .lineLimit(1)
                        .foregroundStyle(ChronosPalette.goldBright)

                    Spacer(minLength: 8)

                    Button("Kaydet") {
                        dismiss()
                    }
                    .font(.system(size: 13, weight: .bold, design: .serif))
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                    .foregroundStyle(ChronosPalette.goldBright)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(ChronosPalette.goldAmber.opacity(0.16))
                    )
                }
                .padding(.horizontal, 18)
                .padding(.top, 18)
                .padding(.bottom, 12)
                .background(ChronosPalette.obsidianCard)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(ChronosPalette.goldAmber.opacity(0.2))
                        .frame(height: 1)
                }

                ScrollView {
                    VStack(spacing: 18) {
                        // 1. Durations Section ("Süreler (Dakika)")
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Süreler (Dakika)", systemImage: "clock.fill")
                                .font(.system(size: 14, weight: .bold, design: .serif))
                                .foregroundStyle(ChronosPalette.goldBright)

                            HStack(spacing: 8) {
                                durationStepperCard(
                                    title: "Odaklanma",
                                    value: $viewModel.settings.focusMinutes,
                                    range: 1...120
                                )
                                durationStepperCard(
                                    title: "Kısa Mola",
                                    value: $viewModel.settings.shortBreakMinutes,
                                    range: 1...60
                                )
                                durationStepperCard(
                                    title: "Uzun Mola",
                                    value: $viewModel.settings.longBreakMinutes,
                                    range: 1...90
                                )
                            }

                            HStack(spacing: 8) {
                                Text("Uzun Mola Sıklığı (Döngü sayısı):")
                                    .font(.system(size: 12, weight: .medium, design: .serif))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                    .foregroundStyle(ChronosPalette.goldPrimary.opacity(0.85))

                                Spacer(minLength: 4)

                                HStack(spacing: 8) {
                                    Button {
                                        viewModel.settings.sessionsBeforeLongBreak = max(2, viewModel.settings.sessionsBeforeLongBreak - 1)
                                    } label: {
                                        Image(systemName: "minus")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundStyle(ChronosPalette.goldBright)
                                            .frame(width: 26, height: 26)
                                            .background(
                                                RoundedRectangle(cornerRadius: 7, style: .continuous)
                                                    .fill(Color.black.opacity(0.55))
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                                                            .strokeBorder(ChronosPalette.goldAmber.opacity(0.35), lineWidth: 1)
                                                    )
                                            )
                                    }
                                    .buttonStyle(.plain)

                                    Text("\(viewModel.settings.sessionsBeforeLongBreak) döngü")
                                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                                        .lineLimit(1)
                                        .fixedSize(horizontal: true, vertical: false)
                                        .frame(minWidth: 54)
                                        .foregroundStyle(ChronosPalette.goldBright)

                                    Button {
                                        viewModel.settings.sessionsBeforeLongBreak = min(12, viewModel.settings.sessionsBeforeLongBreak + 1)
                                    } label: {
                                        Image(systemName: "plus")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundStyle(ChronosPalette.goldBright)
                                            .frame(width: 26, height: 26)
                                            .background(
                                                RoundedRectangle(cornerRadius: 7, style: .continuous)
                                                    .fill(Color.black.opacity(0.55))
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                                                            .strokeBorder(ChronosPalette.goldAmber.opacity(0.35), lineWidth: 1)
                                                    )
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.top, 4)
                        }
                        .padding(16)
                        .background(chronosSectionCard)

                        // 2. Auto Transitions ("Otomatik Geçişler")
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Otomatik Geçişler", systemImage: "play.circle.fill")
                                .font(.system(size: 14, weight: .bold, design: .serif))
                                .foregroundStyle(ChronosPalette.goldBright)

                            Toggle(isOn: $viewModel.settings.autoStartBreaks) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Otomatik Mola Başlat")
                                        .font(.system(size: 13, weight: .semibold, design: .serif))
                                        .foregroundStyle(ChronosPalette.goldBright)
                                    Text("Odaklanma bittiğinde molayı beklemeden başlat")
                                        .font(.system(size: 11, design: .serif))
                                        .foregroundStyle(ChronosPalette.goldPrimary.opacity(0.65))
                                }
                            }
                            .tint(ChronosPalette.goldAmber)

                            Divider().background(ChronosPalette.goldAmber.opacity(0.2))

                            Toggle(isOn: $viewModel.settings.autoStartFocus) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Otomatik Odaklanma Başlat")
                                        .font(.system(size: 13, weight: .semibold, design: .serif))
                                        .foregroundStyle(ChronosPalette.goldBright)
                                    Text("Mola bittiğinde yeni odaklanma seansını başlat")
                                        .font(.system(size: 11, design: .serif))
                                        .foregroundStyle(ChronosPalette.goldPrimary.opacity(0.65))
                                }
                            }
                            .tint(ChronosPalette.goldAmber)
                        }
                        .padding(16)
                        .background(chronosSectionCard)

                        // 3. Sound & Notifications ("Ses ve Bildirimler")
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Ses ve Bildirimler", systemImage: "speaker.wave.2.fill")
                                .font(.system(size: 14, weight: .bold, design: .serif))
                                .foregroundStyle(ChronosPalette.goldBright)

                            Toggle(isOn: $viewModel.settings.soundEnabled) {
                                Text("Bitiş Zil Sesi")
                                    .font(.system(size: 13, weight: .semibold, design: .serif))
                                    .foregroundStyle(ChronosPalette.goldBright)
                            }
                            .tint(ChronosPalette.goldAmber)

                            if viewModel.settings.soundEnabled {
                                VStack(spacing: 12) {
                                    HStack(spacing: 6) {
                                        Text("Ses Tonu:")
                                            .font(.system(size: 12, weight: .medium, design: .serif))
                                            .lineLimit(1)
                                            .fixedSize(horizontal: true, vertical: false)
                                            .foregroundStyle(ChronosPalette.goldPrimary.opacity(0.85))

                                        Spacer(minLength: 2)

                                        Picker("Ses Tonu", selection: $viewModel.settings.soundTheme) {
                                            ForEach(ChronosSoundTheme.allCases) { theme in
                                                Text(theme.title).tag(theme)
                                            }
                                        }
                                        .pickerStyle(.menu)
                                        .lineLimit(1)
                                        .tint(ChronosPalette.goldBright)

                                        Button("Dene") {
                                            viewModel.testAlertSound()
                                        }
                                        .font(.system(size: 11, weight: .bold, design: .serif))
                                        .lineLimit(1)
                                        .fixedSize(horizontal: true, vertical: false)
                                        .foregroundStyle(.black)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(
                                            Capsule().fill(ChronosPalette.goldPrimary)
                                        )
                                    }

                                    VStack(spacing: 4) {
                                        HStack {
                                            Text("Ses Düzeyi")
                                                .font(.system(size: 11, design: .serif))
                                                .foregroundStyle(ChronosPalette.goldPrimary.opacity(0.8))
                                            Spacer()
                                            Text("%\(viewModel.settings.soundVolume)")
                                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                                .foregroundStyle(ChronosPalette.goldBright)
                                        }
                                        Slider(
                                            value: Binding(
                                                get: { Double(viewModel.settings.soundVolume) },
                                                set: { viewModel.settings.soundVolume = Int($0) }
                                            ),
                                            in: 0...100,
                                            step: 1
                                        )
                                        .tint(ChronosPalette.goldAmber)
                                    }
                                }
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(Color.black.opacity(0.4))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .strokeBorder(ChronosPalette.goldAmber.opacity(0.2), lineWidth: 1)
                                        )
                                )
                            }

                            Toggle(isOn: $viewModel.settings.notificationsEnabled) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Bildirimler")
                                        .font(.system(size: 13, weight: .semibold, design: .serif))
                                        .foregroundStyle(ChronosPalette.goldBright)
                                    Text("Süre bittiğinde bildirim uyarısı al")
                                        .font(.system(size: 11, design: .serif))
                                        .foregroundStyle(ChronosPalette.goldPrimary.opacity(0.65))
                                }
                            }
                            .tint(ChronosPalette.goldAmber)

                            Toggle(isOn: $viewModel.settings.hapticsEnabled) {
                                Text("Dokunsal Geri Bildirim (Haptic)")
                                    .font(.system(size: 13, weight: .semibold, design: .serif))
                                    .foregroundStyle(ChronosPalette.goldBright)
                            }
                            .tint(ChronosPalette.goldAmber)
                        }
                        .padding(16)
                        .background(chronosSectionCard)

                        // 4. Theme Appearance ("Görünüm / Tema")
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Görünüm / Tema", systemImage: "paintpalette.fill")
                                .font(.system(size: 14, weight: .bold, design: .serif))
                                .foregroundStyle(ChronosPalette.goldBright)

                            ForEach(ChronosAppTheme.allCases) { theme in
                                let isSelected = viewModel.settings.appTheme == theme
                                Button {
                                    withAnimation(.easeInOut(duration: 0.25)) {
                                        viewModel.settings.appTheme = theme
                                    }
                                } label: {
                                    HStack(spacing: 10) {
                                        Image(systemName: theme.symbolName)
                                            .font(.system(size: 15, weight: .bold))
                                            .foregroundStyle(ChronosPalette.goldPrimary)
                                            .frame(width: 34, height: 34)
                                            .background(
                                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                    .fill(ChronosPalette.goldAmber.opacity(0.18))
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                            .strokeBorder(ChronosPalette.goldAmber.opacity(0.4), lineWidth: 1)
                                                    )
                                            )

                                        VStack(alignment: .leading, spacing: 3) {
                                            HStack(spacing: 6) {
                                                Text(theme.title)
                                                    .font(.system(size: 12.5, weight: .bold, design: .serif))
                                                    .lineLimit(1)
                                                    .minimumScaleFactor(0.8)
                                                    .foregroundStyle(ChronosPalette.goldBright)

                                                if theme == .chronos {
                                                    Text("ÖNERİLEN")
                                                        .font(.system(size: 8.5, weight: .bold, design: .serif))
                                                        .lineLimit(1)
                                                        .fixedSize(horizontal: true, vertical: false)
                                                        .foregroundStyle(ChronosPalette.goldBright)
                                                        .padding(.horizontal, 6)
                                                        .padding(.vertical, 2)
                                                        .background(
                                                            Capsule()
                                                                .fill(ChronosPalette.goldAmber.opacity(0.25))
                                                        )
                                                }
                                            }

                                            Text(theme.subtitle)
                                                .font(.system(size: 11, design: .serif))
                                                .lineLimit(2)
                                                .minimumScaleFactor(0.85)
                                                .foregroundStyle(ChronosPalette.goldPrimary.opacity(0.75))
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                        if isSelected {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 16))
                                                .foregroundStyle(ChronosPalette.goldPrimary)
                                        }
                                    }
                                    .padding(12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .fill(isSelected ? ChronosPalette.goldAmber.opacity(0.18) : Color.black.opacity(0.4))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                    .strokeBorder(
                                                        isSelected ? ChronosPalette.goldPrimary : ChronosPalette.goldAmber.opacity(0.22),
                                                        lineWidth: isSelected ? 1.5 : 1
                                                    )
                                            )
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(16)
                        .background(chronosSectionCard)
                    }
                    .padding(16)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func durationStepperCard(title: String, value: Binding<Int>, range: ClosedRange<Int>) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.system(size: 11, weight: .medium, design: .serif))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .foregroundStyle(ChronosPalette.goldPrimary.opacity(0.8))

            HStack(spacing: 5) {
                Button {
                    value.wrappedValue = max(range.lowerBound, value.wrappedValue - 1)
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(ChronosPalette.goldBright)
                        .frame(width: 22, height: 22)
                        .background(Circle().fill(ChronosPalette.goldAmber.opacity(0.2)))
                }
                .buttonStyle(.plain)

                Text("\(value.wrappedValue)")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .foregroundStyle(ChronosPalette.goldBright)
                    .frame(minWidth: 26)

                Button {
                    value.wrappedValue = min(range.upperBound, value.wrappedValue + 1)
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(ChronosPalette.goldBright)
                        .frame(width: 22, height: 22)
                        .background(Circle().fill(ChronosPalette.goldAmber.opacity(0.2)))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 5)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.black.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(ChronosPalette.goldAmber.opacity(0.25), lineWidth: 1)
                )
        )
    }

    private var chronosSectionCard: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(Color.black.opacity(0.45))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(ChronosPalette.goldAmber.opacity(0.22), lineWidth: 1)
            )
    }
}
