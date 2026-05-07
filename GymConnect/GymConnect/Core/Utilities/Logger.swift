import Foundation
import os.log

struct Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.gymconnect"
    
    static let auth = OSLog(subsystem: subsystem, category: "Auth")
    static let database = OSLog(subsystem: subsystem, category: "Database")
    static let network = OSLog(subsystem: subsystem, category: "Network")
    static let ui = OSLog(subsystem: subsystem, category: "UI")
    static let general = OSLog(subsystem: subsystem, category: "General")
    
    static func debug(_ message: String, log: OSLog = general) {
        #if DEBUG
        os_log(.debug, log: log, "%{public}@", message)
        #endif
    }
    
    static func info(_ message: String, log: OSLog = general) {
        os_log(.info, log: log, "%{public}@", message)
    }
    
    static func error(_ message: String, log: OSLog = general, error: Error? = nil) {
        if let error = error {
            os_log(.error, log: log, "%{public}@ - Error: %{public}@", message, error.localizedDescription)
        } else {
            os_log(.error, log: log, "%{public}@", message)
        }
    }
    
    static func fault(_ message: String, log: OSLog = general) {
        os_log(.fault, log: log, "%{public}@", message)
    }
}