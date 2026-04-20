//
//  WatchConnectivityManager.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/4/7.
//

import Foundation
import WatchConnectivity
 
@Observable
final class WatchConnectivityManager: NSObject {
 
    static let shared = WatchConnectivityManager()
 
    var isWatchReachable = false
 
    /// Called when the watch sends a task action.
    /// waterAmountMl is the already-adjusted amount the user saw on the watch.
    var onTaskActionReceived: ((
        _ taskId: Int64,
        _ action: WatchTaskAction,
        _ reason: String?,
        _ waterAmountMl: Int?
    ) -> Void)?
 
    private var session: WCSession?
 
    private override init() {
        super.init()
    }
 
    // MARK: - Activate
 
    func activate() {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()
        self.session = session
    }
 
    // MARK: - Send Tasks
 
    /// Convert CareTaskItems to display-ready PortableTasks and send to watch.
    /// Coefficients are applied here, so the watch only sees final amounts.
    func sendTasks(today: [CareTaskItem], upcoming: [CareTaskItem]) {
        print("[iOS] sendTasks called: today=\(today.count) upcoming=\(upcoming.count)")
        guard let session else {
            print("[iOS] no session"); return
        }
        print("[iOS] installed=\(session.isWatchAppInstalled) reachable=\(session.isReachable) activation=\(session.activationState.rawValue)")
        guard session.isWatchAppInstalled else { return }

        let payload = WatchPayloadEncoder.encodeSyncTasks(
            today: today.map { Self.portable(from: $0) },
            upcoming: upcoming.map { Self.portable(from: $0) }
        )

        session.transferUserInfo(payload)
        print("[iOS] transferUserInfo queued")

        if session.isReachable {
            session.sendMessage(payload, replyHandler: nil) { error in
                print("[iOS] sendMessage failed: \(error.localizedDescription)")
            }
            print("[iOS] sendMessage attempted")
        }
    }
    /// Build a display-ready PortableTask from a CareTaskItem.
    /// Applies the coefficient calculation so waterAmountMl is the adjusted value.
    private static func portable(from task: CareTaskItem) -> PortableTask {
        let adjustedAmount = task.displayedWaterAmountMl ?? task.waterAmountMl
        return PortableTask(
            id: task.id,
            careType: task.careType,
            scheduledDate: task.scheduledDate,
            status: task.status,
            daysUntil: task.daysUntil,
            waterAmountMl: adjustedAmount,
            feedingType: task.feedingType,
            plantNickname: task.plantNickname,
            plantLocation: task.plantLocation
        )
    }
 
    // MARK: - Tokens
 
    func sendTokens() {
        guard let session, session.isWatchAppInstalled else { return }
        guard let access = KeychainHelper.read(key: KeychainHelper.accessTokenKey),
              let refresh = KeychainHelper.read(key: KeychainHelper.refreshTokenKey)
        else { return }
 
        let payload = WatchPayloadEncoder.encodeTokens(access: access, refresh: refresh)
        session.transferUserInfo(payload)
    }
 
    // MARK: - Task Result
 
    func sendTaskResult(_ result: PortableTaskResult) {
        guard let session, session.isReachable else { return }
        let payload = WatchPayloadEncoder.encodeTaskResult(result)
        session.sendMessage(payload, replyHandler: nil) { error in
            print("[WatchSync] Result send failed: \(error.localizedDescription)")
        }
    }
 
    // MARK: - Handle Incoming
 
    private func handleMessage(_ message: [String: Any]) {
        guard let type = WatchPayloadDecoder.messageType(from: message) else { return }
 
        switch type {
        case .taskAction:
            guard let action = WatchPayloadDecoder.decodeTaskAction(from: message) else { return }
            DispatchQueue.main.async { [weak self] in
                self?.onTaskActionReceived?(
                    action.taskId,
                    action.action,
                    action.reason,
                    action.waterAmountMl
                )
            }
 
        case .requestSync:
            NotificationCenter.default.post(name: .watchRequestedSync, object: nil)
 
        default:
            break
        }
    }
}
 
// MARK: - WCSessionDelegate
 
extension WatchConnectivityManager: WCSessionDelegate {
 
    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        DispatchQueue.main.async { [weak self] in
            self?.isWatchReachable = session.isReachable
        }
        if activationState == .activated {
            sendTokens()
        }
        if let error {
            print("[WatchSync] Activation error: \(error.localizedDescription)")
        }
    }
 
    func sessionDidBecomeInactive(_ session: WCSession) {}
 
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
 
    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async { [weak self] in
            self?.isWatchReachable = session.isReachable
        }
    }
 
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        handleMessage(message)
    }
 
    func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        handleMessage(message)
        replyHandler(["received": true])
    }
 
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        handleMessage(userInfo)
    }
}
 
extension Notification.Name {
    static let watchRequestedSync = Notification.Name("watchRequestedSync")
}
 
