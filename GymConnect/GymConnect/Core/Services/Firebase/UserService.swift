import Foundation
import FirebaseFirestore
import FirebaseStorage
import FirebaseFirestoreSwift

class UserService {
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    func getUser(id: String) async throws -> User {
        let document = try await db.collection("users").document(id).getDocument()
        
        guard let user = try? document.data(as: User.self) else {
            throw ServiceError.userNotFound
        }
        
        return user
    }
    
    func updateUser(_ user: User) async throws {
        guard let id = user.id else {
            throw ServiceError.invalidUserId
        }
        
        var updatedUser = user
        updatedUser.updatedAt = Date()
        
        try db.collection("users").document(id).setData(from: updatedUser)
    }
    
    func updateProfile(userId: String, updates: [String: Any]) async throws {
        var updates = updates
        updates["updatedAt"] = Timestamp(date: Date())
        
        try await db.collection("users").document(userId).updateData(updates)
    }
    
    func uploadProfilePhoto(userId: String, image: UIImage) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw ServiceError.imageCompressionFailed
        }
        
        let storageRef = storage.reference().child("profile_photos/\(userId).jpg")
        _ = try await storageRef.putDataAsync(imageData)
        let downloadUrl = try await storageRef.downloadURL()
        
        // Update user document with new photo URL
        try await updateProfile(userId: userId, updates: ["profilePhotoUrl": downloadUrl.absoluteString])
        
        return downloadUrl.absoluteString
    }
    
    func getUsersAtGym(gymId: String, currentUserId: String, limit: Int = 20) async throws -> [User] {
        let snapshot = try await db.collection("users")
            .whereField("primaryGymId", isEqualTo: gymId)
            .whereField(FieldPath.documentID(), isNotEqualTo: currentUserId)
            .order(by: FieldPath.documentID())
            .order(by: "lastActive", descending: true)
            .limit(to: limit)
            .getDocuments()
        
        return try snapshot.documents.compactMap { try $0.data(as: User.self) }
    }
    
    func searchUsers(query: String, gymId: String) async throws -> [User] {
        // Note: Firestore doesn't support full-text search natively
        // For MVP, we'll do client-side filtering
        // In production, consider Algolia or Elasticsearch
        let snapshot = try await db.collection("users")
            .whereField("primaryGymId", isEqualTo: gymId)
            .limit(to: 100)
            .getDocuments()
        
        let users = try snapshot.documents.compactMap { try $0.data(as: User.self) }
        
        let lowerQuery = query.lowercased()
        return users.filter { user in
            user.displayName.lowercased().contains(lowerQuery)
        }
    }
    
    func blockUser(blockerId: String, blockedId: String) async throws {
        let block = Block(blockerId: blockerId, blockedId: blockedId)
        try db.collection("blocks").addDocument(from: block)
    }
    
    func unblockUser(blockerId: String, blockedId: String) async throws {
        let snapshot = try await db.collection("blocks")
            .whereField("blockerId", isEqualTo: blockerId)
            .whereField("blockedId", isEqualTo: blockedId)
            .getDocuments()
        
        for doc in snapshot.documents {
            try await doc.reference.delete()
        }
    }
    
    func getBlockedUsers(userId: String) async throws -> [String] {
        let snapshot = try await db.collection("blocks")
            .whereField("blockerId", isEqualTo: userId)
            .getDocuments()
        
        return snapshot.documents.compactMap { $0.data()["blockedId"] as? String }
    }
}

enum ServiceError: Error {
    case userNotFound
    case invalidUserId
    case imageCompressionFailed
    case gymNotFound
}