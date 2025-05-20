# ✅ Taskly – iOS Task Manager App

A clean and minimalistic **task management app** built for iOS using **SwiftUI** and **SwiftData**. Taskly helps users organize tasks by due date, mark them as completed, and manage their day efficiently — all wrapped in a beautiful native interface.

![Platform](https://img.shields.io/badge/platform-iOS-blue?logo=apple)
![Swift](https://img.shields.io/badge/language-Swift-orange?logo=swift)
![License](https://img.shields.io/badge/license-Apache--2.0-blue)
![Framework](https://img.shields.io/badge/framework-SwiftUI-informational)

---

## ✨ Features

- 🗂️ Create, edit, and delete tasks
- 📆 Due date selection via `HorizontalDateStrip`
- ✅ Completion toggle per task
- 🧠 Task sections: Overdue, Today, Upcoming
- 📝 Notes and optional details for each task
- 🔔 Notification reminders (via `NotificationService`)
- 🎨 Native iOS 18+ styling with SwiftUI
- 🧪 SwiftData persistence
- 🧭 Tab-based navigation (Tasks, Settings, Onboarding)

---

## 🚀 Getting Started

### Requirements

- Xcode 16.3+
- iOS 18+ simulator or device
- Swift 5.9+
- macOS 15 Sequoia or newer

### 🧑‍💻 Run the App

1. Clone the repository:
   ```bash
   git clone https://github.com/hadzicni/taskly-ios.git
   cd taskly-ios
   ```

2. Open `Taskly.xcodeproj` in Xcode.

3. Build & run using your preferred iOS simulator.

---

## 📦 Dependencies

Taskly uses only native Apple frameworks:

- SwiftUI
- UserNotifications
- Foundation

No third-party packages are required.

---

## 📱 Screens & Views

| View                      | Purpose                              |
|---------------------------|--------------------------------------|
| `TaskListView`            | Main screen with task sections       |
| `CreateTaskView`          | New task input view                  |
| `EditTaskView`            | Inline editing of tasks              |
| `HorizontalDateStrip`     | Custom date picker for due dates     |
| `SettingsView`            | App settings and info                |
| `OnboardingView`          | Initial welcome screen               |
| `TaskRowView`             | Compact task display per row         |

---

## 🧠 Model & Storage

- `Task.swift`: Core model (id, title, dueDate, isCompleted, note)
- Notifications managed via `NotificationService.swift`

---

## 🧪 Testing

You can run previews or unit test components using SwiftUI’s built-in preview canvas and simulator.

---

## 👨‍💻 Author

Made by **Nikola Hadzic**  
GitHub: [@hadzicni](https://github.com/hadzicni)

---

## 📄 License

This project is licensed under the Apache License 2.0. See the [LICENSE](./LICENSE) file for details.

