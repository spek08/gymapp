import Foundation
import FirebaseFirestoreSwift

struct Report: Identifiable, Codable {
    @DocumentID var id: String?
    
    var reporterId: String
    var reportedId: String
    
    var type: ReportType
    var contentId: String?
    
    var reason: Reason
    var description: String?
    
    var status: Status
    
    var createdAt: Date
    var resolvedAt: Date?
    var resolvedBy: String?
    var resolution: String?
    var actionTaken: ActionTaken
    
    enum ReportType: String, Codable {
        case user = "user"
        case message = "message"
        case content = "content"
    }
    
    enum Reason: String, Codable, CaseIterable {
        case harassment = "Harassment"
        case inappropriateContent = "Inappropriate Content"
        case fakeProfile = "Fake Profile"
        case spam = "Spam"
        case threats = "Threats"
        case other = "Other"
    }
    
    enum Status: String, Codable {
        case open = "open"
        case underReview = "under_review"
        case resolved = "resolved"
        case dismissed = "dismissed"
    }
    
    enum ActionTaken: String, Codable {
        case none = "none"
        case warning = "warning"
        case tempBan = "temp_ban"
        case permanentBan = "permanent_ban"
    }
    
    init(id: String? = nil,
         reporterId: String,
         reportedId: String,
         type: ReportType,
         reason: Reason,
         description: String? = nil,
         contentId: String? = nil) {
        self.id = id
        self.reporterId = reporterId
        self.reportedId = reportedId
        self.type = type
        self.reason = reason
        self.description = description
        self.contentId = contentId
        self.status = .open
        self.createdAt = Date()
        self.actionTaken = .none
    }
}

struct Block: Identifiable, Codable {
    @DocumentID var id: String?
    
    var blockerId: String
    var blockedId: String
    
    var createdAt: Date
    var permanent: Bool
    var reason: String?
    
    init(id: String? = nil,
         blockerId: String,
         blockedId: String,
         permanent: Bool = true,
         reason: String? = nil) {
        self.id = id
        self.blockerId = blockerId
        self.blockedId = blockedId
        self.createdAt = Date()
        self.permanent = permanent
        self.reason = reason
    }
}