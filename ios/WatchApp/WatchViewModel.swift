import WatchConnectivity
import SwiftUI

class WatchViewModel: NSObject, ObservableObject, WCSessionDelegate {
    @Published var routineName: String = "Sincronizza..."
    @Published var tasks: [[String: Any]] = []
    @Published var bedtimeTasks: [[String: Any]] = []
    @Published var lastUpdate: String = ""

    static let shared = WatchViewModel()

    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    // MARK: - WCSessionDelegate

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Sessione attivata
    }

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    #endif

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.async {
            self.updateData(from: applicationContext)
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            self.updateData(from: message)
        }
    }

    private func updateData(from data: [String: Any]) {
        if let name = data["name"] as? String {
            self.routineName = name
        }
        if let tasks = data["tasks"] as? [[String: Any]] {
            self.tasks = tasks
        }
        if let bedtimeTasks = data["bedtimeTasks"] as? [[String: Any]] {
            self.bedtimeTasks = bedtimeTasks
        }
        if let lastUpdate = data["lastUpdate"] as? String {
            self.lastUpdate = lastUpdate
        }
    }
}
