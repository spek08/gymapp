import Foundation
import FirebaseFirestoreSwift

struct Chat: Identifiable, Codable {
    @DocumentID var id: String?
    
    var participants: [String]
    var participantGymIds: [String]
    
    var createdAt: Date
    var updatedAt: Date
    
    var lastMessage: LastMessage?
    
    var initiatedBy: String
    var blockStatus: [String: Bool]?
    
    struct LastMessage: Codable {
        var text: String
        var senderId: String
        var timestamp: Date
        var read: Bool
        var readAt: Date?
    }
    
    var otherParticipantId(currentUserId: String) -> String? {
        participants.first { $0 != currentUserId }
    }
    
    init(id: String? = nil,
         participants: [String],
         participantGymIds: [String] = [],
         initiatedBy: String) {
        self.id = id
        self.participants = participants
        self.participantGymIds = participantGymIds
        self.createdAt = Date()
        self.updatedAt = Date()
        self.initiatedBy = initiatedBy
    }
}

struct Message: Identifiable, Codable {
    @DocumentID var id: String?
    
    var senderId: String
    var text: String
    
    var type: MessageType
    
    var timestamp: Date
    var editedAt: Date?
    
    var read: Bool
    var readAt: Date?
    
    var imageUrl: String?
    var imageWidth: Double?
    var imageHeight: Double?
    
    var flagged: Bool
    var flaggedReason: String?
    
    enum MessageType: String, Codable {
        case text = "text"
        case image = "image"
        case system = "system"
    }
    
    init(id: String? = nil,
         senderId: String,
         text: String,
         type: MessageType = .text,
         timestamp: Date = Date()) {
        self.id = id
        self.senderId = senderId
        self.text = text
        self.type = type
        self.timestamp = timestamp
        self.read = false
        self.flagged = false
    }
}