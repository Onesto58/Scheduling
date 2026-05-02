import WatchConnectivity
import SwiftUI

class WatchViewModel: NSObject, ObservableObject, WCSessionDelegate {
    @Published var routineName: String = "Nessuna Routine"
    @Published var tasks: [[String: Any]] = []
    @Published var bedtimeTasks: [[String: Any]] = []
    @Published var lastUpdate: String = ""

    static let shared = WatchViewModel()

    override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Sessione attivata
    }

    // Ricezione dati tramite Application Context (metodo preferito)
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.async {
            self.updateData(from: applicationContext)
        }
    }

    // Ricezione messaggi immediati
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            self.updateData(from: message)
        }
    }

    private func updateData(from data: [String: Any]) {
        self.routineName = data["name"] as? String ?? "Routine"
        self.tasks = data["tasks"] as? [[String: Any]] ?? []
        self.bedtimeTasks = data["bedtimeTasks"] as? [[String: Any]] ?? []
        self.lastUpdate = data["lastUpdate"] as? String ?? ""
    }
}
