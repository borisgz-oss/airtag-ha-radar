import SwiftUI
import AppKit

// =============================================================================
// MARK: - Models
// =============================================================================

struct AirTagItem: Identifiable {
    let id: String
    let name: String
    let icon: String
    var status: String
    var duration: String
    var isHome: Bool
    var lastSeen: String
}

// =============================================================================
// MARK: - State & Sync Manager
// =============================================================================

@MainActor
class SyncManager: ObservableObject {
    @Published var isConnected: Bool = true
    @Published var isSyncing: Bool = false
    @Published var lastSyncText: String = "Just now"
    @Published var haUrl: String {
        didSet { UserDefaults.standard.set(haUrl, forKey: "haUrl") }
    }
    @Published var haToken: String {
        didSet { UserDefaults.standard.set(haToken, forKey: "haToken") }
    }
    @Published var showingSettings: Bool = false
    @Published var syncInterval: Int {
        didSet {
            UserDefaults.standard.set(syncInterval, forKey: "syncInterval")
            restartTimer()
        }
    }
    
    @Published var items: [AirTagItem] = [
        AirTagItem(id: "airtag_car", name: "Car (Автомобиль)", icon: "car.fill", status: "Home (Парковка)", duration: "14h 25m", isHome: true, lastSeen: "2 min ago"),
        AirTagItem(id: "airtag_keys", name: "Keys (Ключи)", icon: "key.fill", status: "Home (В зоне)", duration: "14h 25m", isHome: true, lastSeen: "1 min ago"),
        AirTagItem(id: "airtag_cc", name: "Luggage (Чемодан)", icon: "suitcase.fill", status: "Home (Хранение)", duration: "2d 4h", isHome: true, lastSeen: "5 min ago"),
        AirTagItem(id: "airtag_keys_6zh", name: "Keys 6Ж", icon: "key.horizontal.fill", status: "Home (В зоне)", duration: "14h 25m", isHome: true, lastSeen: "2 min ago")
    ]
    
    private var timer: Timer?

    init() {
        self.haUrl = UserDefaults.standard.string(forKey: "haUrl") ?? "http://homeassistant.local:8123"
        self.haToken = UserDefaults.standard.string(forKey: "haToken") ?? ""
        self.syncInterval = UserDefaults.standard.integer(forKey: "syncInterval")
        if self.syncInterval == 0 { self.syncInterval = 60 }
        
        startTimer()
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: Double(syncInterval), repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.performSync()
            }
        }
    }
    
    func restartTimer() {
        timer?.invalidate()
        startTimer()
    }
    
    func performSync() {
        isSyncing = true
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        
        // Execute background fetch
        DispatchQueue.global(qos: .background).async {
            Thread.sleep(forTimeInterval: 0.8) // Simulated network pulse
            DispatchQueue.main.async {
                self.isSyncing = false
                self.lastSyncText = formatter.string(from: Date())
            }
        }
    }
}

// =============================================================================
// MARK: - Views
// =============================================================================

struct ContentView: View {
    @ObservedObject var manager: SyncManager

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 10) {
                Image(systemName: "location.north.circle.fill")
                    .resizable()
                    .frame(width: 22, height: 22)
                    .foregroundColor(.cyan)

                VStack(alignment: .leading, spacing: 2) {
                    Text("AirTag HA Radar")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Text("Auto-Sync: \(manager.syncInterval)s • \(manager.lastSyncText)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button(action: {
                    manager.showingSettings.toggle()
                }) {
                    Image(systemName: manager.showingSettings ? "chevron.backward" : "gearshape.fill")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)

                Button(action: {
                    manager.performSync()
                }) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.subheadline)
                        .foregroundColor(manager.isSyncing ? .cyan : .secondary)
                        .rotationEffect(.degrees(manager.isSyncing ? 360 : 0))
                        .animation(manager.isSyncing ? Animation.linear(duration: 1).repeatForever(autoreverses: false) : .default, value: manager.isSyncing)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(NSColor.windowBackgroundColor).opacity(0.8))

            Divider()

            if manager.showingSettings {
                settingsView
            } else {
                mainView
            }

            Divider()

            // Footer
            HStack {
                Button("Open HA Dashboard") {
                    if let url = URL(string: "\(manager.haUrl)/airtags-tracking") {
                        NSWorkspace.shared.open(url)
                    }
                }
                .buttonStyle(.borderless)
                .font(.caption)

                Spacer()

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.borderless)
                .font(.caption)
                .foregroundColor(.red)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(NSColor.windowBackgroundColor).opacity(0.5))
        }
        .frame(width: 340)
    }

    private var mainView: some View {
        VStack(spacing: 8) {
            ForEach(manager.items) { item in
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(item.isHome ? Color.green.opacity(0.15) : Color.cyan.opacity(0.15))
                            .frame(width: 32, height: 32)
                        Image(systemName: item.icon)
                            .foregroundColor(item.isHome ? .green : .cyan)
                            .font(.system(size: 14))
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text("\(item.status) • \(item.duration)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Circle()
                        .fill(item.isHome ? Color.green : Color.cyan)
                        .frame(width: 8, height: 8)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
                .cornerRadius(10)
            }

            // Quick Action: Walking to Car
            Button(action: {
                if let url = URL(string: "https://maps.apple.com/?dirflg=w") {
                    NSWorkspace.shared.open(url)
                }
            }) {
                HStack {
                    Image(systemName: "figure.walk")
                        .foregroundColor(.green)
                    Text("Walk to Car (Apple Maps)")
                        .fontWeight(.medium)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
        .padding(14)
    }

    private var settingsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Settings")
                .font(.subheadline)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 4) {
                Text("Home Assistant URL:")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                TextField("http://homeassistant.local:8123", text: $manager.haUrl)
                    .textFieldStyle(.roundedBorder)
                    .font(.caption)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Long-Lived Access Token:")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                SecureField("Bearer token...", text: $manager.haToken)
                    .textFieldStyle(.roundedBorder)
                    .font(.caption)
            }

            HStack {
                Text("Sync Interval:")
                    .font(.caption)
                Spacer()
                Picker("", selection: $manager.syncInterval) {
                    Text("30 sec").tag(30)
                    Text("60 sec").tag(60)
                    Text("2 min").tag(120)
                    Text("5 min").tag(300)
                }
                .pickerStyle(.menu)
                .frame(width: 100)
            }
        }
        .padding(16)
    }
}

// =============================================================================
// MARK: - App Entry Point
// =============================================================================

@main
struct AirTagRadarApp: App {
    @StateObject private var manager = SyncManager()

    var body: some Scene {
        MenuBarExtra("AirTag Radar", systemImage: "location.north.circle.fill") {
            ContentView(manager: manager)
        }
        .menuBarExtraStyle(.window)
    }
}
