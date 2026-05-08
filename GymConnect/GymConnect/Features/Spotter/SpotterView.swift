import SwiftUI

struct SpotterView: View {
    @StateObject private var viewModel = SpotterViewModel()
    @State private var showCreateRequest = false
    
    var body: some View {
        ZStack {
            Color("Background").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Create request button
                Button(action: { showCreateRequest = true }) {
                    HStack {
                        Image(systemName: "hands.sparkles.fill")
                        Text("Need a Spot?")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color("EnergyOrange"))
                    .cornerRadius(12)
                }
                .padding()
                
                // Active requests
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if viewModel.activeRequests.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "hands.sparkles")
                            .font(.system(size: 60))
                            .foregroundColor(Color("TextTertiary"))
                        
                        Text("No active requests")
                            .font(.headline)
                            .foregroundColor(Color("TextSecondary"))
                        
                        Text("Create a request when you need a spotter!")
                            .font(.subheadline)
                            .foregroundColor(Color("TextTertiary"))
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.activeRequests) { request in
                                SpotterRequestCard(
                                    request: request,
                                    requester: nil,
                                    onAccept: { viewModel.acceptRequest(request) }
                                )
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationTitle("Spotter")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showCreateRequest) {
            CreateSpotterRequestView()
        }
        .onAppear {
            viewModel.loadActiveRequests()
        }
    }
}

struct CreateSpotterRequestView: View {
    @Environment(\.dismiss) var dismiss
    @State private var exercise = ""
    @State private var equipment = ""
    @State private var message = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("Background").ignoresSafeArea()
                
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Exercise")
                            .font(.caption)
                            .foregroundColor(Color("TextSecondary"))
                        
                        TextField("e.g., Bench Press", text: $exercise)
                            .padding()
                            .background(Color("SurfaceElevated"))
                            .cornerRadius(12)
                            .foregroundColor(Color("TextPrimary"))
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Equipment (Optional)")
                            .font(.caption)
                            .foregroundColor(Color("TextSecondary"))
                        
                        TextField("e.g., Bench 3", text: $equipment)
                            .padding()
                            .background(Color("SurfaceElevated"))
                            .cornerRadius(12)
                            .foregroundColor(Color("TextPrimary"))
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Message (Optional)")
                            .font(.caption)
                            .foregroundColor(Color("TextSecondary"))
                        
                        TextEditor(text: $message)
                            .frame(height: 100)
                            .padding(8)
                            .background(Color("SurfaceElevated"))
                            .cornerRadius(12)
                            .foregroundColor(Color("TextPrimary"))
                    }
                    
                    Spacer()
                    
                    PrimaryButton(title: "Create Request") {
                        // Create request
                        dismiss()
                    }
                }
                .padding()
            }
            .navigationTitle("Request a Spot")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    CloseButton { dismiss() }
                }
            }
        }
    }
}

class SpotterViewModel: ObservableObject {
    @Published var activeRequests: [SpotterRequest] = []
    @Published var isLoading = false
    
    func loadActiveRequests() {
        // Load from Firestore
    }
    
    func acceptRequest(_ request: SpotterRequest) {
        // Accept request
    }
}

#Preview {
    NavigationView {
        SpotterView()
    }
}