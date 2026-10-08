// swift-tools-version: 5.9
import PackageDescription
let package = Package(name: "agent-diff-ui", platforms: [.iOS(.v17), .macOS(.v14)],
 products:[.library(name:"WhisperaDiffUI",targets:["WhisperaDiffUI"])],
 targets:[.target(name:"WhisperaDiffUI",resources:[.copy("Resources")]),.testTarget(name:"WhisperaDiffUITests",dependencies:["WhisperaDiffUI"])])
