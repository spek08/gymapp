import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    private let authService = AuthService()
    
    init() {
        setupAuthStateListener()
    }
    
    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    private func setupAuthStateListener() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            DispatchQueue.main.async {
                self?.isAuthenticated = firebaseUser != nil
                if let firebaseUser = firebaseUser {
                    self?.fetchUser(userId: firebaseUser.uid)
                } else {
                    self?.currentUser = nil
                }
            }
        }
    }
    
    private func fetchUser(userId: String) {
        Task {
            do {
                let user = try await authService.fetchUser(userId: userId)
                DispatchQueue.main.async {
                    self.currentUser = user
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func sendVerificationCode(to phoneNumber: String) async throws -> String {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let verificationId = try await authService.sendVerificationCode(to: phoneNumber)
            return verificationId
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    func verifyCode(_ code: String, verificationId: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await authService.verifyCode(code, verificationId: verificationId)
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    func signOut() {
        do {
            try authService.signOut()
            currentUser = nil
            isAuthenticated = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - AuthService
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