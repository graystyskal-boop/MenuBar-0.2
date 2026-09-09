import Carbon.HIToolbox
import Cocoa

/// A user-configurable global shortcut, e.g. ⌘⇧Space.
struct KeyCombo: Codable, Equatable {
    var keyCode: UInt32
    var modifiers: UInt32 // Carbon modifier mask (cmdKey, optionKey, controlKey, shiftKey)

    static let defaultCombo = KeyCombo(
        keyCode: UInt32(kVK_Space),
        modifiers: UInt32(cmdKey | shiftKey)
    )

    /// Human-readable label, e.g. "⌘⇧Space", shown in the settings UI.
    var displayString: String {
        var s = ""
        if modifiers & UInt32(controlKey) != 0 { s += "⌃" }
        if modifiers & UInt32(optionKey) != 0 { s += "⌥" }
        if modifiers & UInt32(shiftKey) != 0 { s += "⇧" }
        if modifiers & UInt32(cmdKey) != 0 { s += "⌘" }
        s += KeyCombo.keyName(for: keyCode)
        return s
    }

    static func keyName(for keyCode: UInt32) -> String {
        let specialNames: [UInt32: String] = [
            UInt32(kVK_Space): "Space",
            UInt32(kVK_Return): "Return",
            UInt32(kVK_Tab): "Tab",
            UInt32(kVK_Escape): "Esc",
            UInt32(kVK_Delete): "Delete"
        ]
        if let name = specialNames[keyCode] { return name }

        var deadKeyState: UInt32 = 0
        let maxLength = 4
        var actualLength = 0
        var chars = [UniChar](repeating: 0, count: maxLength)

        guard let source = TISCopyCurrentKeyboardLayoutInputSource()?.takeRetainedValue(),
              let layoutDataPtr = TISGetInputSourceProperty(source, kTISPropertyUnicodeKeyLayoutData) else {
            return "Key\(keyCode)"
        }
        let layoutData = unsafeBitCast(layoutDataPtr, to: CFData.self) as Data
        var result = "Key\(keyCode)"
        layoutData.withUnsafeBytes { rawBufferPointer in
            let keyLayoutPtr = rawBufferPointer.bindMemory(to: UCKeyboardLayout.self).baseAddress
            if let keyLayoutPtr {
                let status = UCKeyTranslate(
                    keyLayoutPtr,
                    UInt16(keyCode),
                    UInt16(kUCKeyActionDown),
                    0,
                    UInt32(LMGetKbdType()),
                    UInt32(kUCKeyTranslateNoDeadKeysBit),
                    &deadKeyState,
                    maxLength,
                    &actualLength,
                    &chars
                )
                if status == noErr && actualLength > 0 {
                    result = String(utf16CodeUnits: chars, count: actualLength).uppercased()
                }
            }
        }
        return result
    }
}

enum KeyComboStore {
    private static let key = "globalHotKeyCombo"

    static func load() -> KeyCombo {
        guard let data = UserDefaults.standard.data(forKey: key),
              let combo = try? JSONDecoder().decode(KeyCombo.self, from: data) else {
            return .defaultCombo
        }
        return combo
    }

    static func save(_ combo: KeyCombo) {
        if let data = try? JSONEncoder().encode(combo) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
