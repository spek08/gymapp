import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class AuthService {
    private let db = Firestore.firestore()
    
    func sendVerificationCode(to phoneNumber: String) async throws -> String {
        // Format phone number
        let formattedNumber = formatPhoneNumber(phoneNumber)
        
        return try await withCheckedThrowingContinuation { continuation in
            PhoneAuthProvider.provider().verifyPhoneNumber(formattedNumber, uiDelegate: nil) { verificationId, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let verificationId = verificationId else {
                    continuation.resume(throwing: AuthError.invalidVerificationId)
                    return
                }
                
                continuation.resume(returning: verificationId)
            }
        }
    }
    
    func verifyCode(_ code: String, verificationId: String) async throws {
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationId,
            verificationCode: code
        )
        
        let result = try await Auth.auth().signIn(with: credential)
        
        // Check if new user
        if result.additionalUserInfo?.isNewUser == true {
            try await createUserDocument(for: result.user)
        }
    }
    
    func fetchUser(userId: String) async throws -> User {
        let document = try await db.collection("users").document(userId).getDocument()
        
        guard let user = try? document.data(as: User.self) else {
            throw AuthError.userNotFound
        }
        
        return user
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    private func createUserDocument(for firebaseUser: FirebaseAuth.User) async throws {
        let user = User(
            id: firebaseUser.uid,
            displayName: "",
            phoneNumber: firebaseUser.phoneNumber ?? "",
            bio: "",
            createdAt: Date()
        )
        
        try db.collection("users").document(firebaseUser.uid).setData(from: user)
    }
    
    private func formatPhoneNumber(_ number: String) -> String {
        let cleaned = number.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        if cleaned.hasPrefix("1") && cleaned.count == 11 {
            return "+\(cleaned)"
        }
        return "+1\(cleaned)"
    }
}

enum AuthError: Error {
    case invalidVerificationId
    case userNotFound
    case invalidPhoneNumber
}
