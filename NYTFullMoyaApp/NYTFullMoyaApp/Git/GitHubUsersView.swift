import SwiftUI

struct GitHubUsersView: View {
    @StateObject private var vm = GitHubUsersViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                if vm.isLoading {
                    ProgressView("Loading GitHub Users...")
                } else if let error = vm.errorMessage {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                } else {
                    List(vm.users) { user in
                        HStack(spacing: 16) {
                            AsyncImage(url: URL(string: user.avatar_url)) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } else {
                                    Color.gray
                                }
                            }
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.login)
                                    .font(.headline)
                                if let type = user.type {
                                    Text("Type: \(type)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                if let htmlURL = URL(string: user.html_url) {
                                    Link("GitHub Profile", destination: htmlURL)
                                        .font(.caption2)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("GitHub Users")
        }
        .task {
            await vm.loadUsers()
        }
    }
}
