import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
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

class HomeViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var isLoading = false
    @Published var showGymSelector = false
    @Published var selectedGymId: String?
    @Published var currentGym: Gym?
    
    func loadUsers() {
        // Implementation will load users from Firestore
    }
    
    func startChat(with user: User) {
        // Navigate to chat
    }
    
    func requestSpot(from user: User) {
        // Show spot request
    }
}

#Preview {
    NavigationView {
        HomeView()
    }
}