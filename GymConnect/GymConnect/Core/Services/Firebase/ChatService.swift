import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

class ChatService {
    private let db = Firestore.firestore()
    
    // MARK: - Chat Operations
    
    func getChats(for userId: String) -> AnyPublisher<[Chat], Error> {
        return db.collection("chats")
            .whereField("participants", arrayContains: userId)
            .order(by: "updatedAt", descending: true)
            .snapshotPublisher()
            .map { snapshot in
                try snapshot.documents.compactMap { try $0.data(as: Chat.self) }
            }
            .eraseToAnyPublisher()
    }
    
    func createChat(participants: [String], initiatedBy: String, gymId: String? = nil) async throws -> String {
        let chat = Chat(
            participants: participants,
            participantGymIds: gymId != nil ? [gymId!] : [],
            initiatedBy: initiatedBy
        )
        
        let docRef = try db.collection("chats").addDocument(from: chat)
        return docRef.documentID
    }
    
    func getOrCreateChat(participants: [String], initiatedBy: String) async throws -> String {
        // Check if chat already exists
        let snapshot = try await db.collection("chats")
            .whereField("participants", arrayContains: initiatedBy)
            .getDocuments()
        
        for doc in snapshot.documents {
            if let chat = try? doc.data(as: Chat.self),
               Set(chat.participants) == Set(participants) {
                return doc.documentID
            }
        }
        
        // Create new chat
        return try await createChat(participants: participants, initiatedBy: initiatedBy)
    }
    
    // MARK: - Message Operations
    
    func getMessages(chatId: String, limit: Int = 50) -> AnyPublisher<[Message], Error> {
        return db.collection("chats").document(chatId).collection("messages")
            .order(by: "timestamp", descending: false)
            .limit(to: limit)
            .snapshotPublisher()
            .map { snapshot in
                try snapshot.documents.compactMap { try $0.data(as: Message.self) }
            }
            .eraseToAnyPublisher()
    }
    
    func sendMessage(chatId: String, senderId: String, text: String) async throws {
        guard Validators.isValidMessage(text) else {
            throw ServiceError.invalidMessage
        }
        
        let message = Message(senderId: senderId, text: text.trimmingCharacters(in: .whitespacesAndNewlines))
        
        let chatRef = db.collection("chats").document(chatId)
        let messageRef = chatRef.collection("messages").document()
        
        try await db.runTransaction { transaction, errorPointer in
            // Add message
            do {
                try transaction.setData(from: message, forDocument: messageRef)
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
            
            // Update chat last message
            transaction.updateData([
                "lastMessage": [
                    "text": message.text,
                    "senderId": message.senderId,
                    "timestamp": Timestamp(date: message.timestamp),
                    "read": false
                ],
                "updatedAt": Timestamp(date: Date())
            ], forDocument: chatRef)
            
            return nil
        }
        
        // Send push notification (handled by Cloud Function in production)
    }
    
    func markMessagesAsRead(chatId: String, userId: String) async throws {
        let messagesRef = db.collection("chats").document(chatId).collection("messages")
        
        let snapshot = try await messagesRef
            .whereField("senderId", isNotEqualTo: userId)
            .whereField("read", isEqualTo: false)
            .getDocuments()
        
        let batch = db.batch()
        
        for doc in snapshot.documents {
            batch.updateData([
                "read": true,
                "readAt": Timestamp(date: Date())
            ], forDocument: doc.reference)
        }
        
        try await batch.commit()
    }
    
    func getUnreadCount(chatId: String, userId: String) async throws -> Int {
        let snapshot = try await db.collection("chats").document(chatId).collection("messages")
            .whereField("senderId", isNotEqualTo: userId)
            .whereField("read", isEqualTo: false)
            .count
            .getAggregation(source: .server)
        
        return snapshot.count
    }
}

// MARK: - Combine Extensions
extension Query {
    func snapshotPublisher() -> AnyPublisher<QuerySnapshot, Error> {
        let subject = PassthroughSubject<QuerySnapshot, Error>()
        
        let listener = addSnapshotListener { snapshot, error in
            if let error = error {
                subject.send(completion: .failure(error))
            } else if let snapshot = snapshot {
                subject.send(snapshot)
            }
        }
        
        return subject
            .handleEvents(receiveCancel: {
                listener.remove()
            })
            .eraseToAnyPublisher()
    }
}