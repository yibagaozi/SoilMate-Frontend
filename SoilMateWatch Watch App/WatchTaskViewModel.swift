//
//  WatchTaskViewModel.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/4/7.
//

import Foundation
import WatchConnectivity
 
@Observable
final class WatchTaskViewModel: NSObject {
 
    static let shared = WatchTaskViewModel()
 
    var todayTasks: [PortableTask] = []
    var upcomingTasks: [PortableTask] = []
    var isConnected = false
    var isLoading = false
 
    /// Set after an action; drives the result screen.
    var lastResult: ActionResult?
 
    struct ActionResult: Identifiable {
        let id = UUID()
        let task: PortableTask
        let action: WatchTaskAction
    }
 
    /// Actions taken while the phone was unreachable; replayed on reconnect.
    private var pendingActions: [(taskId: Int64, action: WatchTaskAction, reason: String?, waterAmountMl: Int?)] = []
 
    private var session: WCSession?
 
    private override init() {
        super.init()
    }
 
    // MARK: - Activate
 
    func activateSession() {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()
        self.session = session
    }
 
    // MARK: - Request Sync
 
    func requestSync() {
        guard let session, session.isReachable else {
            isLoading = false
            return
        }
        isLoading = true
        let message: [String: Any] = [
            WatchMessageKey.type: WatchMessageType.requestSync.rawValue
        ]
        session.sendMessage(message, replyHandler: { _ in
            DispatchQueue.main.async { [weak self] in self?.isLoading = false }
        }, errorHandler: { error in
            print("[Watch] Sync request failed: \(error.localizedDescription)")
            DispatchQueue.main.async { [weak self] in self?.isLoading = false }
        })
    }
 
    // MARK: - Task Actions
 
    func completeTask(_ task: PortableTask) {
        performAction(task: task, action: .complete)
    }
 
    func skipTask(_ task: PortableTask, reason: String? = nil) {
        performAction(task: task, action: .skip, reason: reason)
    }
 
    private func performAction(task: PortableTask, action: WatchTaskAction, reason: String? = nil) {
        // Send the task's waterAmountMl (already calculated by iOS)
        // back so CareLog records what was actually poured.
        let message = WatchPayloadEncoder.encodeTaskAction(
            taskId: task.id,
            action: action,
            reason: reason,
            waterAmountMl: action == .complete ? task.waterAmountMl : nil
        )
 
        // Optimistic removal
        todayTasks.removeAll { $0.id == task.id }
        upcomingTasks.removeAll { $0.id == task.id }
        lastResult = ActionResult(task: task, action: action)
 
        guard let session, session.isReachable else {
            pendingActions.append((task.id, action, reason, task.waterAmountMl))
            return
        }
 
        session.sendMessage(message, replyHandler: nil) { [weak self] error in
            print("[Watch] Action send failed: \(error.localizedDescription)")
            self?.pendingActions.append((task.id, action, reason, task.waterAmountMl))
        }
    }
 
    private func replayPendingActions() {
        guard let session, session.isReachable, !pendingActions.isEmpty else { return }
 
        let actions = pendingActions
        pendingActions.removeAll()
 
        for pending in actions {
            let message = WatchPayloadEncoder.encodeTaskAction(
                taskId: pending.taskId,
                action: pending.action,
                reason: pending.reason,
                waterAmountMl: pending.waterAmountMl
            )
            session.sendMessage(message, replyHandler: nil) { [weak self] error in
                print("[Watch] Replay failed: \(error.localizedDescription)")
                self?.pendingActions.append(pending)
            }
        }
    }
 
    // MARK: - Handle Incoming
 
    private func handleMessage(_ message: [String: Any]) {
        guard let type = WatchPayloadDecoder.messageType(from: message) else { return }
 
        switch type {
        case .syncTasks:
            let (today, upcoming) = WatchPayloadDecoder.decodeTasks(from: message)
            DispatchQueue.main.async { [weak self] in
                self?.todayTasks = today
                self?.upcomingTasks = upcoming
                self?.isLoading = false
            }
 
        case .taskResult:
            if let result = WatchPayloadDecoder.decodeTaskResult(from: message), !result.success {
                // iOS reported failure; re-sync to recover from optimistic removal
                requestSync()
            }
 
        case .syncTokens:
            // Store for potential fallback API use. Not actively used in v1.
            if let access = message[WatchMessageKey.accessToken] as? String {
                UserDefaults.standard.set(access, forKey: "accessToken")
            }
            if let refresh = message[WatchMessageKey.refreshToken] as? String {
                UserDefaults.standard.set(refresh, forKey: "refreshToken")
            }
 
        default:
            break
        }
    }
 
    // MARK: - Display Helpers
 
    var hasTodayTasks: Bool { !todayTasks.isEmpty }
    var hasUpcomingTasks: Bool { !upcomingTasks.isEmpty }
    var isEmpty: Bool { todayTasks.isEmpty && upcomingTasks.isEmpty }
 
    func relativeDayText(for task: PortableTask) -> String {
        guard let days = task.daysUntil else { return task.scheduledDate }
        switch days {
        case ..<0:  return "Overdue"
        case 0:     return "Today"
        case 1:     return "Tomorrow"
        default:    return "In \(days) Days"
        }
    }
}
 
// MARK: - WCSessionDelegate
 
extension WatchTaskViewModel: WCSessionDelegate {
 
    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        DispatchQueue.main.async { [weak self] in
            self?.isConnected = session.isReachable
        }
        if activationState == .activated {
            DispatchQueue.main.async { [weak self] in self?.requestSync() }
        }
        if let error {
            print("[Watch] Activation error: \(error.localizedDescription)")
        }
    }
 
    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async { [weak self] in
            self?.isConnected = session.isReachable
        }
        if session.isReachable {
            replayPendingActions()
            requestSync()
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
