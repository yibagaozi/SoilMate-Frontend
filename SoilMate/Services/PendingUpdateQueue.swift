//
//  PendingUpdateQueue.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/4/9.
//

import Foundation

// MARK: - Model

enum PendingAction: String, Codable {
    case complete = "COMPLETE"
    case skip = "SKIP"
}

struct PendingUpdate: Codable {
    let taskId: Int64
    let action: PendingAction
    let waterAmountMl: Int?
    let skipReason: String?
    let timestamp: Date
}

// MARK: - Queue

actor PendingUpdateQueue {

    static let shared = PendingUpdateQueue()
    private init() {}

    private var fileURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("pending_updates.json")
    }

    // MARK: - Enqueue

    /// Add an update. If an entry for the same task already exists,
    /// the new one replaces it (last write wins).
    func enqueue(_ update: PendingUpdate) {
        var all = load()
        all.removeAll { $0.taskId == update.taskId }
        all.append(update)
        save(all)
    }

    /// Convenience getter so the UI can show a "pending sync" badge if it wants.
    func count() -> Int {
        load().count
    }

    // MARK: - Flush

    /// Try to send every queued update. Successful and server-wins
    /// items are dropped; failures stay for the next flush.
    func flush() async {
        var remaining: [PendingUpdate] = []

        for update in load() {
            do {
                try await send(update)
                // Server accepted; drop.
            } catch let err as ApiError {
                switch err {
                case .notFound, .conflict(_):
                    // Server already has different state; server wins, drop.
                    break
                default:
                    remaining.append(update)
                }
            } catch {
                remaining.append(update)
            }
        }

        save(remaining)
    }

    private func send(_ update: PendingUpdate) async throws {
        switch update.action {
        case .complete:
            let req = CompleteTaskRequest(
                waterAmountMl: update.waterAmountMl,
                feedingType: nil,
                notes: nil
            )
            _ = try await CareTaskService.completeTask(id: update.taskId, request: req)

        case .skip:
            let req = update.skipReason.map { SkipTaskRequest(reason: $0) }
            _ = try await CareTaskService.skipTask(id: update.taskId, request: req)
        }
    }

    // MARK: - Persistence

    private func load() -> [PendingUpdate] {
        guard let data = try? Data(contentsOf: fileURL) else { return [] }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode([PendingUpdate].self, from: data)) ?? []
    }

    private func save(_ updates: [PendingUpdate]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(updates) else { return }
        try? data.write(to: fileURL)
    }
}
