import Foundation
import FirebaseFirestoreSwift

struct SpotterRequest: Identifiable, Codable {
    @DocumentID var id: String?
    
    var requesterId: String
    var gymId: String
    
    var status: Status
    
    var message: String?
    var exercise: String?
    var equipment: String?
    var estimatedDuration: Int?
    
    var createdAt: Date
    var expiresAt: Date
    var acceptedAt: Date?
    var completedAt: Date?
    
    var acceptedBy: String?
    var responderMessage: String?
    
    var isPublic: Bool
    
    var requesterRating: Int?
    var responderRating: Int?
    
    enum Status: String, Codable {
        case active = "active"
        case accepted = "accepted"
        case completed = "completed"
        case cancelled = "cancelled"
        case expired = "expired"
        case declined = "declined"
    }
    
    var isActive: Bool {
        status == .active
    }
    
    var isExpired: Bool {
        Date() > expiresAt
    }
    
    init(id: String? = nil,
         requesterId: String,
         gymId: String,
         message: String? = nil,
         exercise: String? = nil,
         equipment: String? = nil,
         estimatedDuration: Int? = nil,
         isPublic: Bool = true) {
        self.id = id
        self.requesterId = requesterId
        self.gymId = gymId
        self.status = .active
        self.message = message
        self.exercise = exercise
        self.equipment = equipment
        self.estimatedDuration = estimatedDuration
        self.createdAt = Date()
        self.expiresAt = Date().addingTimeInterval(30 * 60) // 30 minutes
        self.isPublic = isPublic
    }
}