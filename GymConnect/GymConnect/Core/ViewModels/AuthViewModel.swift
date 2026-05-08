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