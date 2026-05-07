import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                DiscoverView()
            }
            .tabItem {
                Image(systemName: "person.2.fill")
                Text("Discover")
            }
            .tag(0)
            
            NavigationView {
                SpotterView()
            }
            .tabItem {
                Image(systemName: "hands.sparkles.fill")
                Text("Spotter")
            }
            .tag(1)
            
            NavigationView {
                ChatListView()
            }
            .tabItem {
                Image(systemName: "message.fill")
                Text("Messages")
            }
            .tag(2)
            
            NavigationView {
                ProfileView()
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("Profile")
            }
            .tag(3)
        }
        .accentColor(Color("PrimaryBlue"))
    }
}

struct DiscoverView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = DiscoverViewModel()
    
    var body: some View {
        ZStack {
            Color("Background").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Gym header
                if let gym = viewModel.currentGym {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(gym.name)
                                .font(.headline)
                                .foregroundColor(Color("TextPrimary"))
                            
                            Text("\(gym.activeCheckins) people here now")
                                .font(.caption)
                                .foregroundColor(Color("SuccessGreen"))
                        }
                        
                        Spacer()
                        
                        Button(action: { viewModel.showGymSelector = true }) {
                            Image(systemName: "arrow.triangle.swap")
                                .foregroundColor(Color("PrimaryBlue"))
                        }
                    }
                    .padding()
                    .background(Color("Surface"))
                }
                
                // Users list
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.5)
                    Spacer()
                } else if viewModel.users.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "person.2.slash")
                            .font(.system(size: 60))
                            .foregroundColor(Color("TextTertiary"))
                        
                        Text("No users found")
                            .font(.headline)
                            .foregroundColor(Color("TextSecondary"))
                        
                        Text("Be the first to join this gym!")
                            .font(.subheadline)
                            .foregroundColor(Color("TextTertiary"))
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.users) { user in
                                UserCard(
                                    user: user,
                                    onMessage: { viewModel.startChat(with: user) },
                                    onSpotRequest: { viewModel.requestSpot(from: user) }
                                )
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationTitle("Discover")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $viewModel.showGymSelector) {
            GymSelectorView(selectedGymId: $viewModel.selectedGymId)
        }
        .onAppear {
            viewModel.loadUsers()
        }
    }
}

class DiscoverViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var isLoading = false
    @Published var showGymSelector = false
    @Published var selectedGymId: String?
    @Published var currentGym: Gym?
    
    private let userService = UserService()
    private let gymService = GymService()
    
    func loadUsers() {
        isLoading = true
        
        Task {
            // Load users at gym
            // This would be implemented with actual service calls
            
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
    
    func startChat(with user: User) {
        // Navigate to chat
    }
    
    func requestSpot(from user: User) {
        // Show spot request sheet
    }
}

struct SpotterView: View {
    var body: some View {
        Text("Spotter View")
    }
}

struct ChatListView: View {
    var body: some View {
        Text("Chat List")
    }
}

struct ProfileView: View {
    var body: some View {
        Text("Profile View")
    }
}

struct GymSelectorView: View {
    @Binding var selectedGymId: String?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Text("Gym Selector")
    }
}

#Preview("Main Tab") {
    MainTabView()
        .environmentObject(AuthViewModel())
}