import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var phoneNumber = ""
    @State private var showVerification = false
    @State private var verificationId = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("Background").ignoresSafeArea()
                
                VStack(spacing: 32) {
                    Spacer()
                    
                    // Logo
                    GymConnectLogo(style: .icon, size: .xlarge)
                    
                    VStack(spacing: 8) {
                        Text("Welcome to GymConnect")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color("TextPrimary"))
                        
                        Text("Find your gym squad in Oklahoma City")
                            .font(.body)
                            .foregroundColor(Color("TextSecondary"))
                            .multilineTextAlignment(.center)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 24) {
                        PhoneInputField(
                            text: $phoneNumber,
                            placeholder: "(405) 555-0123"
                        )
                        
                        PrimaryButton(
                            title: "Continue",
                            isLoading: authViewModel.isLoading,
                            isDisabled: !isValidPhone
                        ) {
                            Task {
                                do {
                                    verificationId = try await authViewModel.sendVerificationCode(
                                        to: phoneNumber
                                    )
                                    showVerification = true
                                } catch {
                                    // Error handled in ViewModel
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Privacy note
                    Text("By continuing, you agree to our Terms of Service and Privacy Policy")
                        .font(.caption)
                        .foregroundColor(Color("TextTertiary"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .padding(24)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showVerification) {
                VerificationView(
                    verificationId: verificationId,
                    phoneNumber: phoneNumber
                )
                .environmentObject(authViewModel)
            }
            .alert("Error", isPresented: .constant(authViewModel.errorMessage != nil)) {
                Button("OK") { authViewModel.errorMessage = nil }
            } message: {
                Text(authViewModel.errorMessage ?? "")
            }
        }
    }
    
    private var isValidPhone: Bool {
        let cleaned = phoneNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        return cleaned.count == 10
    }
}

struct VerificationView: View {
    let verificationId: String
    let phoneNumber: String
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var code = ""
    @State private var resendTimer = 60
    @State private var timer: Timer?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("Background").ignoresSafeArea()
                
                VStack(spacing: 32) {
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Text("Enter Verification Code")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color("TextPrimary"))
                        
                        Text("We sent a code to \(phoneNumber)")
                            .font(.body)
                            .foregroundColor(Color("TextSecondary"))
                            .multilineTextAlignment(.center)
                    }
                    
                    Spacer()
                    
                    VerificationCodeInput(code: $code, length: 6)
                    
                    PrimaryButton(
                        title: "Verify",
                        isLoading: authViewModel.isLoading,
                        isDisabled: code.count != 6
                    ) {
                        Task {
                            do {
                                try await authViewModel.verifyCode(code, verificationId: verificationId)
                                dismiss()
                            } catch {
                                // Error handled in ViewModel
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Resend code
                    Button(action: resendCode) {
                        if resendTimer > 0 {
                            Text("Resend code in \(resendTimer)s")
                                .font(.subheadline)
                                .foregroundColor(Color("TextTertiary"))
                        } else {
                            Text("Resend code")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color("PrimaryBlue"))
                        }
                    }
                    .disabled(resendTimer > 0)
                }
                .padding(24)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    CloseButton {
                        dismiss()
                    }
                }
            }
            .onAppear {
                startTimer()
            }
            .onDisappear {
                timer?.invalidate()
            }
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if resendTimer > 0 {
                resendTimer -= 1
            }
        }
    }
    
    private func resendCode() {
        Task {
            do {
                _ = try await authViewModel.sendVerificationCode(to: phoneNumber)
                resendTimer = 60
                startTimer()
            } catch {
                // Error handled in ViewModel
            }
        }
    }
}

#Preview("Login") {
    LoginView()
        .environmentObject(AuthViewModel())
}

#Preview("Verification") {
    VerificationView(verificationId: "test", phoneNumber: "(405) 555-0123")
        .environmentObject(AuthViewModel())
}