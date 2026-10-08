# agent-diff-ui
Independent Swift package for iOS 17+ and macOS 14+, wrapping [@pierre/diffs](https://github.com/pierrecomputer/pierre/tree/main/packages/diffs) in an offline, read-only WebKit surface.

```swift
import WhisperaDiffUI
AgentDiffView(patch: unifiedPatch, dark: true, split: false, wrap: true)
```

Supports actual patch headers and line offsets, syntax highlighting, word changes, unified/split views and light/dark themes. Incomplete patches show their original text rather than fabricating a comparison. The host supplies authenticated patch retrieval and sheet/navigation controls; this package does not read your repository or run git. Resources are bundled, networking is disabled by CSP and navigation policy, and WebKit uses an ephemeral data store.

Swift wrapper: MIT. Pierre engine: Apache-2.0; bundled dependency notices are in `THIRD_PARTY_NOTICES`. To rebuild: `cd scripts && npm ci --ignore-scripts && npm run build`. Engine version is pinned to 1.3.5.
