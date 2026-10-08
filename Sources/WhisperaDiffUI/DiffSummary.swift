import Foundation
/// A preview of a raw unified patch; headers are never counted as changes.
public struct DiffSummary: Equatable, Sendable {
    public let files: [String]
    public let additions: Int
    public let deletions: Int
    public init?(_ patch: String) {
        let lines = patch.components(separatedBy: "\n")
        guard lines.contains(where: { $0.hasPrefix("@@ ") }), lines.contains(where: { $0.hasPrefix("+++ ") }), lines.contains(where: { $0.hasPrefix("--- ") }) else { return nil }
        files = lines.filter { $0.hasPrefix("+++ ") }.map { String($0.dropFirst(4)).replacingOccurrences(of: "b/", with: "", options: .anchored) }
        additions = lines.filter { $0.hasPrefix("+") && !$0.hasPrefix("+++") }.count
        deletions = lines.filter { $0.hasPrefix("-") && !$0.hasPrefix("---") }.count
    }
}
