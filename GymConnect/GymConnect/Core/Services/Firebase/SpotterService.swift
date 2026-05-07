import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

class SpotterService {
    private let db = Firestore.firestore()
    
    // MARK: - Request Operations
    
    func createRequest(_ request: SpotterRequest) async throws {
        try db.collection("spotterRequests").addDocument(from: request)
        
        // Update user's current request (optional, for tracking)
        // This could be done in a Cloud Function
    }
    
    func getActiveRequests(gymId: String) -> AnyPublisher<[SpotterRequest], Error> {
        return db.collection("spotterRequests")
            .whereField("gymId", isEqualTo: gymId)
            .whereField("status", isEqualTo: SpotterRequest.Status.active.rawValue)
            .order(by: "createdAt", descending: true)
            .snapshotPublisher()
            .map { snapshot in
                try snapshot.documents.compactMap { try $0.data(as: SpotterRequest.self) }
            }
            .eraseToAnyPublisher()
    }
    
    func getMyRequests(userId: String) async throws -> [SpotterRequest] {
        let snapshot = try await db.collection("spotterRequests")
            .whereField("requesterId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .limit(to: 20)
            .getDocuments()
        
        return try snapshot.documents.compactMap { try $0.data(as: SpotterRequest.self) }
    }
    
    func getMyAcceptedRequests(userId: String) async throws -> [SpotterRequest] {
        let snapshot = try await db.collection("spotterRequests")
            .whereField("acceptedBy", isEqualTo: userId)
            .order(by: "acceptedAt", descending: true)
            .limit(to: 20)
            .getDocuments()
        
        return try snapshot.documents.compactMap { try $0.data(as: SpotterRequest.self) }
    }
    
    // MARK: - Request Actions
    
    func acceptRequest(requestId: String, userId: String) async throws {
        let requestRef = db.collection("spotterRequests").document(requestId)
        
        try await requestRef.updateData([
            "status": SpotterRequest.Status.accepted.rawValue,
            "acceptedBy": userId,
            "acceptedAt": Timestamp(date: Date())
        ])
    }
    
    func completeRequest(requestId: String) async throws {
        let requestRef = db.collection("spotterRequests").document(requestId)
        
        try await requestRef.updateData([
            "status": SpotterRequest.Status.completed.rawValue,
            "completedAt": Timestamp(date: Date())
        ])
    }
    
    func cancelRequest(requestId: String) async throws {
        let requestRef = db.collection("spotterRequests").document(requestId)
        
        try await requestRef.updateData([
            "status": SpotterRequest.Status.cancelled.rawValue
        ])
    }
    
    // MARK: - Cleanup
    
    func expireOldRequests() async throws {
        let cutoffDate = Date().addingTimeInterval(-30 * 60) // 30 minutes ago
        
        let snapshot = try await db.collection("spotterRequests")
            .whereField("status", isEqualTo: SpotterRequest.Status.active.rawValue)
            .whereField("expiresAt", isLessThan: Timestamp(date: cutoffDate))
            .getDocuments()
        
        let batch = db.batch()
        
        for doc in snapshot.documents {
            batch.updateData([
                "status": SpotterRequest.Status.expired.rawValue
            ], forDocument: doc.reference)
        }
        
        try await batch.commit()
    }
}