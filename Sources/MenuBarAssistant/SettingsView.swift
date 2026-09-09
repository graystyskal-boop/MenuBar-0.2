import SwiftUI

struct SettingsView: View {
    @State private var combo: KeyCombo
    @State private var isRecording = false
    @State private var modelName: String

    let onComboChanged: (KeyCombo) -> Void

    init(initialCombo: KeyCombo, onComboChanged: @escaping (KeyCombo) -> Void) {
        _combo = State(initialValue: initialCombo)
        let stored = UserDefaults.standard.string(forKey: "ollamaModelName") ?? ""
        _modelName = State(initialValue: stored.isEmpty ? "llama3.2" : stored)
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

            Section("Local Model (Ollama)") {
                TextField("llama3.2", text: $modelName)
                    .onChange(of: modelName) { _, newValue in
                        UserDefaults.standard.set(newValue, forKey: "ollamaModelName")
                    }
                Text("No API key needed — this talks to Ollama running locally at 127.0.0.1:11434.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(20)
        .frame(width: 380, height: 260)
    }
}
