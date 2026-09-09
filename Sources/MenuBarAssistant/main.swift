import Cocoa

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

// .accessory keeps us out of the Dock/app switcher (belt-and-suspenders
// with LSUIElement in Info.plist) while still running as a normal,
// fully visible background process.
app.setActivationPolicy(.accessory)

app.run()
