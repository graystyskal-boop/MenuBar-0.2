import Carbon.HIToolbox
import Cocoa

/// Registers a single global hotkey via the Carbon Event Manager.
/// Event-driven (no polling), so it costs essentially nothing while idle.
final class HotKeyManager {
    private var hotKeyRef: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?
    private let hotKeyID = EventHotKeyID(signature: OSType(1_146_442_818), id: 1) // 'MBAT'

    var onTrigger: (() -> Void)?

    private(set) var currentCombo: KeyCombo

    init(initialCombo: KeyCombo) {
        self.currentCombo = initialCombo
        installEventHandler()
        register(combo: initialCombo)
    }

    deinit {
        unregister()
        if let eventHandler {
            RemoveEventHandler(eventHandler)
        }
    }

    func updateCombo(_ combo: KeyCombo) {
        unregister()
        currentCombo = combo
        register(combo: combo)
        KeyComboStore.save(combo)
    }

    private func installEventHandler() {
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        let selfPtr = Unmanaged.passUnretained(self).toOpaque()

        InstallEventHandler(GetApplicationEventTarget(), { _, eventRef, userData in
            guard let userData, let eventRef else { return noErr }
            let manager = Unmanaged<HotKeyManager>.fromOpaque(userData).takeUnretainedValue()
            var hkID = EventHotKeyID()
            GetEventParameter(eventRef, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), nil, MemoryLayout<EventHotKeyID>.size, nil, &hkID)
            if hkID.id == manager.hotKeyID.id {
                DispatchQueue.main.async {
                    manager.onTrigger?()
                }
            }
            return noErr
        }, 1, &eventType, selfPtr, &eventHandler)
    }

    private func register(combo: KeyCombo) {
        RegisterEventHotKey(
            combo.keyCode,
            combo.modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
    }

    private func unregister() {
        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }
    }
}
