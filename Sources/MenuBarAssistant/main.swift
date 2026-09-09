import Cocoa

@MainActor
final class AppLauncher {
    // A static let keeps AppDelegate alive for the process lifetime —
    // NSApplication.delegate is a weak reference, so without this the
    // delegate would be deallocated right after assignment.
    static let delegate = AppDelegate()

    static func run() {
        let app = NSApplication.shared
        app.delegate = delegate
        // .accessory keeps us out of the Dock/app switcher (belt-and-suspenders
        // with LSUIElement in Info.plist) while still running as a normal,
        // fully visible background process.
        app.setActivationPolicy(.accessory)
        app.run()
    }
}

MainActor.assumeIsolated {
    AppLauncher.run()
}
