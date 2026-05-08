import SwiftUI

struct ChatListView: View {
    @StateObject private var viewModel = ChatListViewModel()
    
    var body: some View {
        ZStack {
            Color("Background").ignoresSafeArea()
            
            VStack(spacing: 0) {
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if viewModel.chats.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "message.slash")
                            .font(.system(size: 60))
                            .foregroundColor(Color("TextTertiary"))
                        
                        Text("No messages yet")
                            .font(.headline)
                            .foregroundColor(Color("TextSecondary"))
                        
                        Text("Start chatting with gym buddies!")
                            .font(.subheadline)
                            .foregroundColor(Color("TextTertiary"))
                    }
                    Spacer()
                } else {
                    List(viewModel.chats) { chat in
                        ChatRow(chat: chat)
                            .listRowBackground(Color("Surface"))
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }
                    .listStyle(PlainListStyle())
                }
            }
        }
        .navigationTitle("Messages")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { viewModel.showNewChat = true }) {
                    Image(systemName: "square.and.pencil")
                        .foregroundColor(Color("PrimaryBlue"))
                }
            }
        }
        .onAppear {
            viewModel.loadChats()
        }
    }
}

struct ChatRow: View {
    let chat: Chat
    
    var body: some View {
        Button(action: { /* Navigate to chat */ }) {
            HStack(spacing: 12) {
                // Avatar placeholder
                Circle()
                    .fill(Color("SurfaceElevated"))
                    .frame(width: 56, height: 56)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(Color("TextTertiary"))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("User Name")
                        .font(.headline)
                        .foregroundColor(Color("TextPrimary"))
                    
                    if let lastMessage = chat.lastMessage {
                        Text(lastMessage.text)
                            .font(.subheadline)
                            .foregroundColor(lastMessage.read ? Color("TextSecondary") : Color("TextPrimary"))
                            .lineLimit(1)
                    } else {
                        Text("No messages yet")
                            .font(.subheadline)
                            .foregroundColor(Color("TextTertiary"))
                            .italic()
                    }
                }
                
                Spacer()
                
                if let lastMessage = chat.lastMessage, !lastMessage.read {
                    Circle()
                        .fill(Color("EnergyOrange"))
                        .frame(width: 10, height: 10)
                }
            }
            .padding(.vertical, 8)
        }
    }
}

class ChatListViewModel: ObservableObject {
    @Published var chats: [Chat] = []
    @Published var isLoading = false
    @Published var showNewChat = false
    
    func loadChats() {
        // Load chats from Firestore
    }
}

#Preview {
    NavigationView {
        ChatListView()
    }
}