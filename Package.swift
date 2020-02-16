// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "LyricsKit",
    platforms: [
        .macOS(.v10_10),
        .iOS(.v8),
        .tvOS(.v9),
        .watchOS(.v2),
    ],
    products: [
        .library(
            name: "LyricsKit",
            targets: ["LyricsCore", "LyricsService"]),
    ],
    dependencies: [
        .package(url: "https://github.com/cx-org/CombineX", .upToNextMinor(from: "0.1.0")),
        .package(url: "https://github.com/cx-org/CXExtensions", .upToNextMinor(from: "0.1.0")),
        .package(url: "https://github.com/ddddxxx/Regex", .upToNextMinor(from: "0.2.0")),
        .package(url: "https://github.com/1024jp/GzipSwift", from: "5.0.0"),
    ],
    targets: [
        .target(
            name: "LyricsCore",
            dependencies: ["Regex"]),
        .target(
            name: "LyricsService",
            dependencies: ["LyricsCore", "CXShim", "CXExtensions", "Regex", "Gzip"]),
        .testTarget(
            name: "LyricsKitTests",
            dependencies: ["LyricsCore", "LyricsService"]),
    ],
    swiftLanguageVersions: [
        .v5
    ]
)

enum CombineImplementation {
    
    case combine
    case combineX
    case openCombine
    
    static var `default`: CombineImplementation {
        #if canImport(Combine)
        return .combine
        #else
        return .combineX
        #endif
    }
    
    init?(_ description: String) {
        let desc = description.lowercased().filter { $0.isLetter }
        switch desc {
        case "combine":     self = .combine
        case "combinex":    self = .combineX
        case "opencombine": self = .openCombine
        default:            return nil
        }
    }
}

import Foundation

let env = ProcessInfo.processInfo.environment
let impkey = "CX_COMBINE_IMPLEMENTATION"

var combineImp = env[impkey].flatMap(CombineImplementation.init) ?? .default

if combineImp == .combine {
    package.platforms = [.macOS("10.15"), .iOS("13.0"), .tvOS("13.0"), .watchOS("6.0")]
}
