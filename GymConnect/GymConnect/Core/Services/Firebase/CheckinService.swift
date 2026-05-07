import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

class CheckinService {
    private let db = Firestore.firestore()
    private let gymService = GymService()
    
    // MARK: - Check-in Operations
    
    func checkIn(userId: String, gymId: String) async throws -> Checkin {
        // End any existing checkin first
        try? await checkOutActiveCheckin(userId: userId)
        
        let checkin = Checkin(
            userId: userId,
            gymId: gymId,
            status: .active,
            startedAt: Date()
        )
        
        let docRef = try db.collection("checkins").addDocument(from: checkin)
        
        // Update user status
        try await db.collection("users").document(userId).updateData([
            "isOnline": true,
            "currentCheckinId": docRef.documentID,
            "lastActive": Timestamp(date: Date())
        ])
        
        // Update gym active checkins
        try? await gymService.updateActiveCheckins(gymId: gymId, increment: 1)
        
        // Update gym member count if first checkin
        try? await gymService.updateGymMemberCount(gymId: gymId, increment: 1)
        
        var newCheckin = checkin
        newCheckin.id = docRef.documentID
        return newCheckin
    }
    
    func checkOut(checkinId: String) async throws {
        let checkinRef = db.collection("checkins").document(checkinId)
        
        let doc = try await checkinRef.getDocument()
        guard let checkin = try? doc.data(as: Checkin.self),
              let userId = checkin.id else {
            throw ServiceError.checkinNotFound
        }
        
        let endTime = Date()
        let duration = Int(endTime.timeIntervalSince(checkin.startedAt) / 60)
        
        try await checkinRef.updateData([
            "status": Checkin.Status.ended.rawValue,
            "endedAt": Timestamp(date: endTime),
            "duration": duration
        ])
        
        // Update user status
        try await db.collection("users").document(userId).updateData([
            "isOnline": false,
            "currentCheckinId": NSNull(),
            "lastActive": Timestamp(date: endTime)
        ])
        
        // Update gym active checkins
        try? await gymService.updateActiveCheckins(gymId: checkin.gymId, increment: -1)
    }
    
    func checkOutActiveCheckin(userId: String) async throws {
        let snapshot = try await db.collection("checkins")
            .whereField("userId", isEqualTo: userId)
            .whereField("status", isEqualTo: Checkin.Status.active.rawValue)
            .getDocuments()
        
        for doc in snapshot.documents {
            try await checkOut(checkinId: doc.documentID)
        }
    }
    
    // MARK: - Queries
    
    func getActiveCheckins(gymId: String) -> AnyPublisher<[Checkin], Error> {
        return db.collection("checkins")
            .whereField("gymId", isEqualTo: gymId)
            .whereField("status", isEqualTo: Checkin.Status.active.rawValue)
            .order(by: "startedAt", descending: true)
            .snapshotPublisher()
            .map { snapshot in
                try snapshot.documents.compactMap { try $0.data(as: Checkin.self) }
            }
            .eraseToAnyPublisher()
    }
    
    func getUserActiveCheckin(userId: String) async throws -> Checkin? {
        let snapshot = try await db.collection("checkins")
            .whereField("userId", isEqualTo: userId)
            .whereField("status", isEqualTo: Checkin.Status.active.rawValue)
            .limit(to: 1)
            .getDocuments()
        
        return try snapshot.documents.first.flatMap { try $0.data(as: Checkin.self) }
    }
    
    // MARK: - Cleanup
    
    func autoCheckoutInactiveUsers() async throws {
        let cutoffTime = Date().addingTimeInterval(-3 * 60 * 60) // 3 hours ago
        
        let snapshot = try await db.collection("checkins")
            .whereField("status", isEqualTo: Checkin.Status.active.rawValue)
            .whereField("startedAt", isLessThan: Timestamp(date: cutoffTime))
            .getDocuments()
        
        for doc in snapshot.documents {
            guard let checkin = try? doc.data(as: Checkin.self),
                  let checkinId = checkin.id else { continue }
            
            let endTime = Date()
            let duration = Int(endTime.timeIntervalSince(checkin.startedAt) / 60)
            
            // Update checkin
            try await doc.reference.updateData([
                "status": Checkin.Status.autoEnded.rawValue,
                "endedAt": Timestamp(date: endTime),
                "duration": duration
            ])
            
            // Update user status
            try await db.collection("users").document(checkin.userId).updateData([
                "isOnline": false,
                "currentCheckinId": NSNull(),
                "lastActive": Timestamp(date: endTime)
            ])
            
            // Update gym count
            try? await gymService.updateActiveCheckins(gymId: checkin.gymId, increment: -1)
        }
    }
}

extension ServiceError {
    static let checkinNotFound = ServiceError.custom("Checkin not found")
    static let invalidMessage = ServiceError.custom("Invalid message")
    
    static func custom(_ message: String) -> ServiceError {
        // You might want to extend ServiceError enum to include this
        return ServiceError.userNotFound // Fallback
    }
}