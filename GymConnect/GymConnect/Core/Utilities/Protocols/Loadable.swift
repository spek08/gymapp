import Foundation

protocol Loadable: ObservableObject {
    associatedtype Data
    var data: Data? { get set }
    var isLoading: Bool { get set }
    var error: Error? { get set }
    
    func load()
}

protocol Validatable {
    var isValid: Bool { get }
    var validationError: String? { get }
    
    func validate() -> Bool
}

protocol AuthServiceProtocol {
    var isAuthenticated: Bool { get }
    var currentUserId: String? { get }
    
    func signIn(withPhoneNumber phone: String) async throws -> String
    func verifyCode(_ code: String, verificationId: String) async throws
    func signInWithApple(credential: Data) async throws
    func signOut() throws
}

protocol UserServiceProtocol {
    func getUser(id: String) async throws -> User
    func updateUser(_ user: User) async throws
    func updateProfile(userId: String, updates: [String: Any]) async throws
    func uploadProfilePhoto(userId: String, image: Data) async throws -> String
}

protocol GymServiceProtocol {
    func getGyms(near location: (lat: Double, lng: Double), radius: Double) async throws -> [Gym]
    func getGym(id: String) async throws -> Gym
    func searchGyms(query: String) async throws -> [Gym]
}

protocol ChatServiceProtocol {
    func getChats(for userId: String) async throws -> [Chat]
    func getMessages(chatId: String, limit: Int) async throws -> [Message]
    func sendMessage(chatId: String, senderId: String, text: String) async throws
    func createChat(participants: [String], initiatedBy: String) async throws -> Chat
}

protocol SpotterServiceProtocol {
    func createRequest(_ request: SpotterRequest) async throws
    func getActiveRequests(gymId: String) async throws -> [SpotterRequest]
    func acceptRequest(requestId: String, userId: String) async throws
    func completeRequest(requestId: String) async throws
    func cancelRequest(requestId: String) async throws
}

protocol CheckinServiceProtocol {
    func checkIn(userId: String, gymId: String) async throws -> Checkin
    func checkOut(checkinId: String) async throws
    func getActiveCheckins(gymId: String) async throws -> [Checkin]
}