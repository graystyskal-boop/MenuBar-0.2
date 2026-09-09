import Carbon.HIToolbox
import SwiftUI

/// A small clickable field: click it, press a key combo, it captures that
/// combo as the new global shortcut.
struct HotkeyRecorderView: NSViewRepresentable {
    @Binding var combo: KeyCombo
    @Binding var isRecording: Bool

    func makeNSView(context: Context) -> RecorderNSView {
        let view = RecorderNSView()
        view.onCapture = { newCombo in
            combo = newCombo
            isRecording = false
        }
        return view
    }

    func updateNSView(_ nsView: RecorderNSView, context: Context) {
        nsView.isRecording = isRecording
        if isRecording {
            nsView.window?.makeFirstResponder(nsView)
        }
    }

    final class RecorderNSView: NSView {
        var onCapture: ((KeyCombo) -> Void)?
        var isRecording = false

        override var acceptsFirstResponder: Bool { true }

        override func keyDown(with event: NSEvent) {
            guard isRecording else {
                super.keyDown(with: event)
                return
            }
            var carbonMods: UInt32 = 0
            if event.modifierFlags.contains(.command) { carbonMods |= UInt32(cmdKey) }
            if event.modifierFlags.contains(.option) { carbonMods |= UInt32(optionKey) }
            if event.modifierFlags.contains(.control) { carbonMods |= UInt32(controlKey) }
            if event.modifierFlags.contains(.shift) { carbonMods |= UInt32(shiftKey) }

            // Require at least one modifier so we don't steal plain
            // letter keys from every other app.
            guard carbonMods != 0 else { return }

            let combo = KeyCombo(keyCode: UInt32(event.keyCode), modifiers: carbonMods)
            onCapture?(combo)
        }
    }
}
