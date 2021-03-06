// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "LyricsKit",
    platforms: [
        .macOS(.v10_10),
        .iOS(.minimalToolChainSupported),
        .tvOS(.v9),
        .watchOS(.v2),
    ],
    products: [
        .library(
            name: "LyricsKit",
            targets: ["LyricsCore", "LyricsService"]),
    ],
    dependencies: [
        .package(url: "https://github.com/cx-org/CombineX", .upToNextMinor(from: "0.3.0")),
        .package(url: "https://github.com/cx-org/CXExtensions", .upToNextMinor(from: "0.3.0")),
        .package(url: "https://github.com/ddddxxx/Regex", .upToNextMinor(from: "0.2.0")),
        .package(url: "https://github.com/ddddxxx/SwiftCF", .upToNextMinor(from: "0.1.4")),
        .package(name: "Gzip", url: "https://github.com/1024jp/GzipSwift", from: "5.0.0"),
    ],
    targets: [
        .target(
            name: "LyricsCore",
            dependencies: [
                "Regex",
                "SwiftCF"
            ]),
        .target(
            name: "LyricsService",
            dependencies: [
                "LyricsCore",
                .product(name: "CXShim", package: "CombineX"),
                "CXExtensions",
                "Regex",
                "Gzip"
            ]),
        .testTarget(
            name: "LyricsKitTests",
            dependencies: [
                "LyricsCore",
                "LyricsService"
            ]),
    ]
)

extension SupportedPlatform.IOSVersion {
    #if compiler(>=5.3)
    static var minimalToolChainSupported = SupportedPlatform.IOSVersion.v9
    #else
    static var minimalToolChainSupported = SupportedPlatform.IOSVersion.v8
    #endif
}

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

extension ProcessInfo {

    var combineImplementation: CombineImplementation {
        return environment["CX_COMBINE_IMPLEMENTATION"].flatMap(CombineImplementation.init) ?? .default
    }
}

import Foundation

if ProcessInfo.processInfo.combineImplementation == .combine {
    package.platforms = [.macOS("10.15"), .iOS("13.0"), .tvOS("13.0"), .watchOS("6.0")]
}
