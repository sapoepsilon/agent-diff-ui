// SPDX-License-Identifier: MIT
import SwiftUI
import WebKit

/// An offline, read-only patch viewer powered by @pierre/diffs. No network or editing.
public struct AgentDiffView: View {
    public var patch: String
    public var dark: Bool
    public var split: Bool
    public var wrap: Bool
    @State private var fallback: String?
    public init(patch: String, dark: Bool = false, split: Bool = false, wrap: Bool = true) {
        self.patch = patch; self.dark = dark; self.split = split; self.wrap = wrap
    }
    public var body: some View {
        VStack(spacing: 0) {
            if let fallback { Text(fallback).font(.caption).foregroundStyle(.secondary).padding(8) }
            DiffWebView(patch: patch, dark: dark, split: split, wrap: wrap, fallback: $fallback)
        }
    }
}

private struct DiffWebView {
    let patch: String
    let dark: Bool
    let split: Bool
    let wrap: Bool
    @Binding var fallback: String?
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    func makeWebView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .nonPersistent()
        configuration.userContentController.add(context.coordinator, name: "diffState")
        let view = WKWebView(frame: .zero, configuration: configuration)
        view.navigationDelegate = context.coordinator
        #if os(iOS)
        view.isOpaque = false
        view.backgroundColor = .clear
        #endif
        if let url = Bundle.module.url(forResource: "index", withExtension: "html") {
            view.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        } else { fallback = "Diff resources could not load." }
        return view
    }
    func update(_ view: WKWebView, context: Context) {
        context.coordinator.parent = self
        if context.coordinator.loaded { context.coordinator.render(view) }
    }
    final class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: DiffWebView
        var loaded = false
        private var rendered: String?
        init(_ parent: DiffWebView) { self.parent = parent }
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) { loaded = true; render(webView) }
        func render(_ view: WKWebView) {
            let signature = parent.patch + "\n" + String(parent.dark) + String(parent.split) + String(parent.wrap)
            guard rendered != signature else { return }; rendered = signature
            Task { @MainActor [weak self] in
                guard let self else { return }
                do { _ = try await view.callAsyncJavaScript("window.showPatch(patch, dark, split, wrap)", arguments: ["patch": self.parent.patch, "dark": self.parent.dark, "split": self.parent.split, "wrap": self.parent.wrap], in: nil, contentWorld: .page) }
                catch { self.parent.fallback = "Diff rendering failed. Reopen the viewer to retry." }
            }
        }
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard let object = message.body as? [String: Any] else { return }
            parent.fallback = object["error"] as? String
        }
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            decisionHandler(navigationAction.request.url?.isFileURL == true ? .allow : .cancel)
        }
    }
}
#if os(iOS)
extension DiffWebView: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView { makeWebView(context: context) }
    func updateUIView(_ view: WKWebView, context: Context) { update(view, context: context) }
}
#elseif os(macOS)
extension DiffWebView: NSViewRepresentable {
    func makeNSView(context: Context) -> WKWebView { makeWebView(context: context) }
    func updateNSView(_ view: WKWebView, context: Context) { update(view, context: context) }
}
#endif
