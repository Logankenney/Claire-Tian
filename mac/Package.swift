// swift-tools-version:5.7
// claire tian crm for macos. built by .github/workflows/mac-app.yml (or ./build.sh on any mac with xcode tools).
import PackageDescription

let package = Package(
    name: "ClaireTianCRM",
    platforms: [.macOS(.v12)],
    targets: [
        .executableTarget(name: "ClaireTianCRM", path: "Sources/ClaireTianCRM")
    ]
)
