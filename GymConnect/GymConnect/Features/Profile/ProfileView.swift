import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showEditProfile = false
    @State private var showSettings = false
    
    var body: some View {
        ZStack {
            Color("Background").ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    if let user = authViewModel.currentUser {
                        ProfileHeader(user: user, isCurrentUser: true) {
                            showEditProfile = true
                        }
                        
                        // Stats section
                        HStack(spacing: 20) {
                            StatCard(title: "Workouts", value: "0")
                            StatCard(title: "Spotter Helps", value: "0")
                            StatCard(title: "Friends", value: "0")
                        }
                        .padding(.horizontal)
                        
                        // Quick actions
                        VStack(spacing: 12) {
                            ProfileButton(icon: "pencil", title: "Edit Profile") {
                                showEditProfile = true
                            }
                            
                            ProfileButton(icon: "gear", title: "Settings") {
                                showSettings = true
                            }
                            
                            ProfileButton(icon: "questionmark.circle", title: "Help & Support") {
                                // Open help
                            }
                            
                            ProfileButton(icon: "arrow.right.square", title: "Sign Out", color: Color("AlertRed")) {
                                authViewModel.signOut()
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showEditProfile) {
            EditProfileView()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color("PrimaryBlue"))
            
            Text(title)
                .font(.caption)
                .foregroundColor(Color("TextSecondary"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color("Surface"))
        .cornerRadius(12)
    }
}

struct ProfileButton: View {
    let icon: String
    let title: String
    var color: Color = Color("TextPrimary")
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                    .frame(width: 32)
                
                Text(title)
                    .font(.body)
                    .foregroundColor(color)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(Color("TextTertiary"))
            }
            .padding()
            .background(Color("Surface"))
            .cornerRadius(12)
        }
    }
}

#Preview {
    NavigationView {
        ProfileView()
            .environmentObject(AuthViewModel())
    }
}