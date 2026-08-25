import Foundation

struct UserSnapshot: Sendable {
    let id: UUID
    let displayName: String
}

final class LockedCounter: @unchecked Sendable {
    private let lock = NSLock()
    private var storage = 0

    func increment() {
        lock.lock()
        storage += 1
        lock.unlock()
    }

    func value() -> Int {
        lock.lock()
        defer { lock.unlock() }
        return storage
    }
}

actor UserStore {
    private var users: [UUID: UserSnapshot] = [:]
    func insert(_ user: UserSnapshot) { users[user.id] = user }
    func count() -> Int { users.count }
}

@main
struct Demo {
    static func main() async {
        let counter = LockedCounter()
        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<100 {
                group.addTask {
                    for _ in 0..<1_000 { counter.increment() }
                }
            }
        }
        print("LockedCounter: \(counter.value()) (expected: 100000)")

        let store = UserStore()
        await withTaskGroup(of: Void.self) { group in
            for number in 0..<100 {
                group.addTask {
                    await store.insert(UserSnapshot(id: UUID(), displayName: "User \(number)"))
                }
            }
        }
        print("Actor-owned snapshots: \(await store.count()) (expected: 100)")
    }
}
