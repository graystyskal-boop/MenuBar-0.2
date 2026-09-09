// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "MenuBarAssistant",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "MenuBarAssistant",
            path: "Sources/MenuBarAssistant",
            exclude: ["Info.plist"],
            linkerSettings: [
                // Embeds Info.plist into the binary so macOS treats this as
                // a background/menu-bar app (no Dock icon, no app switcher entry)
                // even though it's built via SPM instead of an Xcode .app target.
                .unsafeFlags([
                    "-Xlinker", "-sectcreate",
                    "-Xlinker", "__TEXT",
                    "-Xlinker", "__info_plist",
                    "-Xlinker", "Sources/MenuBarAssistant/Info.plist"
                ])
            ]
        )
    ]
)
