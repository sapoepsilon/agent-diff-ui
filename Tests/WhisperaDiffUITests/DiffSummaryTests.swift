import XCTest
@testable import WhisperaDiffUI
final class DiffSummaryTests: XCTestCase {
    func testHeadersAndOffsetsArePreserved() {
        let patch = "diff --git a/App.swift b/App.swift\n--- a/App.swift\n+++ b/App.swift\n@@ -42,2 +42,2 @@\n-old\n+new\n same\n"
        let summary = DiffSummary(patch)
        XCTAssertEqual(summary?.files, ["App.swift"])
        XCTAssertEqual(summary?.additions, 1); XCTAssertEqual(summary?.deletions, 1)
        XCTAssertNil(DiffSummary("+ incomplete terminal snippet"))
    }
}
