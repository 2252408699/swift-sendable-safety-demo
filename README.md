# Swift Sendable Safety Demo

Two practical Swift 6 patterns: immutable `Sendable` snapshots owned by an actor, and a legacy reference type whose `@unchecked Sendable` promise is backed by one lock protecting every access.

## Run

```bash
git clone https://github.com/2252408699/swift-sendable-safety-demo.git
cd swift-sendable-safety-demo
swift run
```

The program performs 100,000 concurrent increments and inserts 100 immutable snapshots. Both final counts are asserted in the printed output.
