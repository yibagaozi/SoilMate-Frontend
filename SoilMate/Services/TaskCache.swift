//
//  TaskCache.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/4/8.
//

import Foundation

enum TaskCache {

    private static var fileURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("today_tasks.json")
    }

    // MARK: - Read / Write

    static func loadTodayTasks() -> [CareTaskItem] {
        guard let data = try? Data(contentsOf: fileURL) else { return [] }
        return (try? JSONDecoder().decode([CareTaskItem].self, from: data)) ?? []
    }

    static func saveTodayTasks(_ tasks: [CareTaskItem]) {
        guard let data = try? JSONEncoder().encode(tasks) else { return }
        try? data.write(to: fileURL)
    }

    /// Remove a single task from the cache (used after the user
    /// completes or skips it locally).
    static func removeTask(id: Int64) {
        var tasks = loadTodayTasks()
        tasks.removeAll { $0.id == id }
        saveTodayTasks(tasks)
    }

    static func clear() {
        try? FileManager.default.removeItem(at: fileURL)
    }
}
