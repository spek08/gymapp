import SwiftUI

struct OnboardingContainer: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var currentStep = 0
    @State private var userProfile = OnboardingProfile()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("Background").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Progress bar
                    ProgressView(value: Double(currentStep + 1), total: 5)
                        .progressViewStyle(LinearProgressViewStyle(tint: Color("PrimaryBlue")))
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                    
                    // Content
                    TabView(selection: $currentStep) {
                        ProfileSetupView(userProfile: $userProfile, onContinue: nextStep)
                            .tag(0)
                        
                        FitnessGoalsView(userProfile: $userProfile, onContinue: nextStep)
                            .tag(1)
                        
                        GymSelectionView(userProfile: $userProfile, onComplete: completeOnboarding)
                            .tag(2)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.easeInOut, value: currentStep)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Skip") {
                        // Skip onboarding (not recommended, but allowed)
                        completeOnboarding()
                    }
                    .foregroundColor(Color("TextSecondary"))
                }
            }
        }
    }
    
    private func nextStep() {
        withAnimation {
            currentStep += 1
        }
    }
    
    private func completeOnboarding() {
        // Save user profile to Firestore
        guard let userId = authViewModel.currentUser?.id else { return }
        
        Task {
            // This would be implemented in UserService
            // For now, just mark onboarding as complete
        }
    }
}

struct OnboardingProfile {
    var displayName = ""
    var bio = ""
    var profilePhoto: UIImage?
    var experienceLevel: User.ExperienceLevel = .beginner
    var fitnessGoals: [User.FitnessGoal] = []
    var selectedGymId: String?
}

struct ProfileSetupView: View {
    @Binding var userProfile: OnboardingProfile
    let onContinue: () -> Void
    
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    Text("Create Your Profile")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color("TextPrimary"))
                    
                    Text("Tell us a bit about yourself")
                        .font(.body)
                        .foregroundColor(Color("TextSecondary"))
                }
                .padding(.top, 32)
                
                // Photo upload
                Button(action: { showImagePicker = true }) {
                    ZStack {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                        } else {
                            Circle()
                                .fill(Color("SurfaceElevated"))
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: "camera.fill")
                                .font(.system(size: 40))
                                .foregroundColor(Color("TextTertiary"))
                        }
                        
                        // Edit indicator
                        Circle()
                            .fill(Color("PrimaryBlue"))
                            .frame(width: 36, height: 36)
                            .overlay(
                                Image(systemName: "pencil")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            )
                            .offset(x: 40, y: 40)
                    }
                }
                
                VStack(spacing: 24) {
                    // Display name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Display Name")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(Color("TextSecondary"))
                        
                        TextField("Enter your name", text: $userProfile.displayName)
                            .font(.body)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(Color("SurfaceElevated"))
                            .cornerRadius(12)
                            .foregroundColor(Color("TextPrimary"))
                    }
                    
                    // Bio
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Bio (Optional)")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(Color("TextSecondary"))
                        
                        TextEditor(text: $userProfile.bio)
                            .font(.body)
                            .frame(height: 100)
                            .padding(8)
                            .background(Color("SurfaceElevated"))
                            .cornerRadius(12)
                            .foregroundColor(Color("TextPrimary"))
                    }
                }
                
                Spacer()
                
                PrimaryButton(
                    title: "Continue",
                    isDisabled: userProfile.displayName.count < 2
                ) {
                    onContinue()
                }
                .padding(.bottom, 32)
            }
            .padding(.horizontal, 24)
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage, isPresented: $showImagePicker)
        }
        .onChange(of: selectedImage) { newImage in
            userProfile.profilePhoto = newImage
        }
    }
}

struct FitnessGoalsView: View {
    @Binding var userProfile: OnboardingProfile
    let onContinue: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    Text("Your Fitness Goals")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color("TextPrimary"))
                    
                    Text("Select up to 5 goals")
                        .font(.body)
                        .foregroundColor(Color("TextSecondary"))
                }
                .padding(.top, 32)
                
                // Experience level
                VStack(alignment: .leading, spacing: 16) {
                    Text("Experience Level")
                        .font(.headline)
                        .foregroundColor(Color("TextPrimary"))
                    
                    ExperienceLevelPicker(selectedLevel: $userProfile.experienceLevel)
                }
                
                // Fitness goals
                VStack(alignment: .leading, spacing: 16) {
                    Text("What are your goals?")
                        .font(.headline)
                        .foregroundColor(Color("TextPrimary"))
                    
                    GoalSelector(
                        selectedGoals: $userProfile.fitnessGoals,
                        maxSelection: 5
                    )
                }
                
                Spacer()
                
                PrimaryButton(
                    title: "Continue",
                    isDisabled: userProfile.fitnessGoals.isEmpty
                ) {
                    onContinue()
                }
                .padding(.bottom, 32)
            }
            .padding(.horizontal, 24)
        }
    }
}

#Preview("Onboarding") {
    OnboardingContainer()
        .environmentObject(AuthViewModel())
}