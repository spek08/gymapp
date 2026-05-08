import SwiftUI
import Combine

enum Route: Hashable {
    case onboarding
    case login
    case main
    case gymSelector
    case userProfile(userId: String)
    case chat(chatId: String)
    case settings
    case editProfile
    case privacySettings
    case notificationSettings
    case blockedUsers
    case help
}

class AppRouter: ObservableObject {
    @Published var path = NavigationPath()
    
    func navigate(to route: Route) {
        path.append(route)
    }
    
    func navigateBack() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    func navigateToRoot() {
        path.removeLast(path.count)
    }
}

struct NavigationModifier: ViewModifier {
    @StateObject private var router = AppRouter()
    
    func body(content: Content) -> some View {
        NavigationStack(path: $router.path) {
            content
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .onboarding:
                        OnboardingContainer()
                    case .login:
                        LoginView()
                    case .main:
                        MainTabView()
                    case .gymSelector:
                        GymSelectorView(selectedGymId: .constant(nil))
                    case .userProfile(let userId):
                        UserProfileView(userId: userId)
                    case .chat(let chatId):
                        ChatView(chatId: chatId)
                    case .settings:
                        SettingsView()
                    case .editProfile:
                        EditProfileView()
                    case .privacySettings:
                        PrivacySettingsView()
                    case .notificationSettings:
                        NotificationSettingsView()
                    case .blockedUsers:
                        BlockedUsersView()
                    case .help:
                        HelpSupportView()
                    }
                }
        }
        .environmentObject(router)
    }
}

extension View {
    func withNavigation() -> some View {
        modifier(NavigationModifier())
    }
}

// Placeholder views for navigation - will be implemented in future
struct UserProfileView: View {
    let userId: String
    var body: some View { Text("User Profile: \(userId)") }
}

struct ChatView: View {
    let chatId: String
    var body: some View { Text("Chat: \(chatId)") }
}

struct SettingsView: View {
    var body: some View { Text("Settings") }
}

struct EditProfileView: View {
    var body: some View { Text("Edit Profile") }
}

struct PrivacySettingsView: View {
    var body: some View { Text("Privacy Settings") }
}

struct NotificationSettingsView: View {
    var body: some View { Text("Notification Settings") }
}

struct BlockedUsersView: View {
    var body: some View { Text("Blocked Users") }
}

struct HelpSupportView: View {
    var body: some View { Text("Help & Support") }
}