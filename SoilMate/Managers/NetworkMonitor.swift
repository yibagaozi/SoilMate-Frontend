//
//  NetworkMonitor.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/4/16.
//


import Foundation
import Network

@Observable
final class NetworkMonitor {

    static let shared = NetworkMonitor()

    var isOnline = true

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "soilmate.network.monitor")
    private var didStart = false

    private init() {}

    func start() {
        guard !didStart else { return }
        didStart = true

        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            let nowOnline = path.status == .satisfied

            DispatchQueue.main.async {
                let wasOnline = self.isOnline
                self.isOnline = nowOnline

                if !wasOnline && nowOnline {
                    NotificationCenter.default.post(name: .networkBecameOnline, object: nil)
                    Task { await PendingUpdateQueue.shared.flush() }
                }
            }
        }

        monitor.start(queue: queue)
    }
}

extension Notification.Name {
    static let networkBecameOnline = Notification.Name("networkBecameOnline")
}
