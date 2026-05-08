import SwiftUI
import MapKit

struct GymSelectorView: View {
    @Binding var selectedGymId: String?
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = GymSelectorViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("Background").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search bar
                    SearchBar(
                        text: $viewModel.searchQuery,
                        placeholder: "Search gyms...",
                        onSubmit: { viewModel.search() }
                    )
                    .padding()
                    
                    // Map view
                    Map(coordinateRegion: $viewModel.region, annotationItems: viewModel.gyms) { gym in
                        MapMarker(coordinate: gym.coordinate, tint: Color("PrimaryBlue"))
                    }
                    .frame(height: 300)
                    
                    // Gym list
                    List(viewModel.gyms) { gym in
                        GymListRow(gym: gym, isSelected: gym.id == selectedGymId) {
                            selectedGymId = gym.id
                            dismiss()
                        }
                        .listRowBackground(Color("Surface"))
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Select Gym")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    CloseButton { dismiss() }
                }
            }
            .onAppear {
                viewModel.loadNearbyGyms()
            }
        }
    }
}

struct GymListRow: View {
    let gym: Gym
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(gym.name)
                        .font(.headline)
                        .foregroundColor(Color("TextPrimary"))
                    
                    Text(gym.address)
                        .font(.subheadline)
                        .foregroundColor(Color("TextSecondary"))
                    
                    HStack {
                        Label("\(gym.gymType.rawValue)", systemImage: gym.gymType.icon)
                            .font(.caption)
                            .foregroundColor(Color("PrimaryBlue"))
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color("SuccessGreen"))
                        .font(.title3)
                }
            }
            .padding(.vertical, 8)
        }
    }
}

class GymSelectorViewModel: ObservableObject {
    @Published var gyms: [Gym] = []
    @Published var searchQuery = ""
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 35.4676, longitude: -97.5164), // Oklahoma City
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    private let gymService = GymService()
    
    func loadNearbyGyms() {
        Task {
            // Load gyms from Firestore
        }
    }
    
    func search() {
        Task {
            // Search gyms
        }
    }
}

#Preview {
    GymSelectorView(selectedGymId: .constant(nil))
}