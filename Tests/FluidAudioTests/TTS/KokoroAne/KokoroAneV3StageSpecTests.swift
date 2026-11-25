import Foundation
import XCTest

@testable import FluidAudio

/// Checks how the ANE-v3 pipeline turns downloaded package names into compile/load specs.
/// The directories hold no model content, so nothing is compiled or loaded here.
final class KokoroAneV3StageSpecTests: XCTestCase {
    private var root: URL!

    override func setUpWithError() throws {
        root = FileManager.default.temporaryDirectory
            .appendingPathComponent("kokoro-v3-spec-\(UUID().uuidString)", isDirectory: true)
        for directory in ["base", "fast", "decoder"] {
            try makeDirectory(root.appendingPathComponent(directory))
        }
        for package in [
            "fast/KokoroAlbert_64.mlpackage", "fast/KokoroAlbert_32.mlpackage",
            "decoder/KokoroDecoderPre_200.mlpackage", "decoder/KokoroDecoderPre_120.mlpackage",
        ] {
            try makeDirectory(root.appendingPathComponent(package))
        }
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: root)
    }

    private func makeDirectory(_ url: URL) throws {
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }

    private func specs(_ units: KokoroAneComputeUnits) throws -> [KokoroAneV3Pipeline.StageSpec] {
        try KokoroAneV3Pipeline.stageSpecs(
            baseDirectory: root.appendingPathComponent("base"),
            fastDirectory: root.appendingPathComponent("fast"),
            decoderDirectory: root.appendingPathComponent("decoder"),
            computeUnits: units)
    }

    func testFastVocoderListsEveryBucketInLoadOrder() throws {
        let keys = try specs(.aneTailGpu).map(\.key)
        XCTAssertEqual(
            keys,
            [
                "Albert", "PostAlbert", "Alignment", "Prosody", "Noise", "Vocoder", "Tail",
                "Albert_32", "Albert_64", "Decoder_120", "Decoder_200", "SourceGenerator",
            ])
    }

    func testBaseStagesUseVersionTwoBundlesForNoiseProsodyAndTail() throws {
        let byKey = Dictionary(uniqueKeysWithValues: try specs(.aneTailCpu).map { ($0.key, $0) })
        XCTAssertEqual(byKey["Noise"]?.name, "KokoroNoise_v2")
        XCTAssertEqual(byKey["Prosody"]?.name, "KokoroProsody_v2")
        XCTAssertEqual(byKey["Tail"]?.name, "KokoroTail_v2")
        XCTAssertEqual(byKey["Albert"]?.name, "KokoroAlbert")
        XCTAssertEqual(byKey["Noise"]?.units, KokoroAneComputeUnits.aneTailCpu.noise)
        XCTAssertEqual(byKey["Tail"]?.units, KokoroAneComputeUnits.aneTailCpu.tail)
        XCTAssertEqual(byKey["Tail"]?.lowPrecision, true)
        XCTAssertEqual(byKey["Albert_32"]?.lowPrecision, false)
    }

    func testMetalFreeRoutingSkipsFastVocoderPackages() throws {
        // The decoder directory is never created in this case, and the spec list must not need it.
        try FileManager.default.removeItem(at: root.appendingPathComponent("decoder"))
        let keys = try specs(.aneTailCpu).map(\.key)
        XCTAssertEqual(
            keys,
            ["Albert", "PostAlbert", "Alignment", "Prosody", "Noise", "Vocoder", "Tail", "Albert_32", "Albert_64"])
    }

    func testMissingAlbertBucketsIsAnError() throws {
        try FileManager.default.removeItem(at: root.appendingPathComponent("fast"))
        XCTAssertThrowsError(try specs(.aneTailCpu))
    }
}
