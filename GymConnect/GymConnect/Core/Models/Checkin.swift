import Foundation
import FirebaseFirestoreSwift

struct Checkin: Identifiable, Codable {
    @DocumentID var id: String?
    
    var userId: String
    var gymId: String
    
    var status: Status
    
    var startedAt: Date
    var endedAt: Date?
    var duration: Int? // minutes
    
    var isVisible: Bool
    
    var locationVerified: Bool
    var locationAccuracy: Double?
    
    enum Status: String, Codable {
        case active = "active"
        case ended = "ended"
        case autoEnded = "auto_ended"
    }
    
    init(id: String? = nil,
         userId: String,
         gymId: String,
         status: Status = .active,
         startedAt: Date = Date(),
         isVisible: Bool = true,
         locationVerified: Bool = false) {
        self.id = id
        self.userId = userId
        self.gymId = gymId
        self.status = status
        self.startedAt = startedAt
        self.isVisible = isVisible
        self.locationVerified = locationVerified
    }
}