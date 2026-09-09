import SwiftUI

struct SettingsView: View {
    @State private var combo: KeyCombo
    @State private var isRecording = false
    @State private var apiKey: String

    let onComboChanged: (KeyCombo) -> Void

    init(initialCombo: KeyCombo, onComboChanged: @escaping (KeyCombo) -> Void) {
        _combo = State(initialValue: initialCombo)
        _apiKey = State(initialValue: UserDefaults.standard.string(forKey: "anthropicApiKey") ?? "")
        self.onComboChanged = onComboChanged
    }

    var body: some View {
        Form {
            Section("Global Shortcut") {
                HStack {
                    Text(isRecording ? "Press a key combo…" : combo.displayString)
                        .frame(width: 140, alignment: .leading)
                        .padding(6)
                        .background(RoundedRectangle(cornerRadius: 6).stroke(Color.secondary))
                    Button(isRecording ? "Cancel" : "Change") {
                        isRecording.toggle()
                    }
                }
                HotkeyRecorderView(combo: $combo, isRecording: $isRecording)
                    .frame(width: 0, height: 0)
                    .onChange(of: combo) { _, newValue in
                        onComboChanged(newValue)
                    }
            }

            Section("Anthropic API Key") {
                SecureField("sk-ant-...", text: $apiKey)
                    .onChange(of: apiKey) { _, newValue in
                        UserDefaults.standard.set(newValue, forKey: "anthropicApiKey")
                    }
                Text("Stored locally in this Mac's user defaults, never sent anywhere except api.anthropic.com.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(20)
        .frame(width: 380, height: 240)
    }
}
