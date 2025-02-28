import SwiftUI
import UIKit

struct MainTabView: View {
    
    let myRestAPIViewModel:MyRestAPIViewModel
    
    var body: some View {
        TabView {
            // “Advanced” Home
            MainHomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            TopStoriesView()
                .tabItem {
                    Label("Top Stories", systemImage: "newspaper.fill")
                }
            
            MostPopularView()
                .tabItem {
                    Label("Popular", systemImage: "star.fill")
                }
            
            BooksView()
                .tabItem {
                    Label("Books", systemImage: "book.fill")
                }
            
            TimesWireView()
                .tabItem {
                    Label("Times Wire", systemImage: "clock.arrow.circlepath")
                }
            
            ArticleSearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            
            FakeStorePostView()
                .tabItem {
                    Label("FakeStore", systemImage: "cart")
                }
            
            GitHubUsersView()
                .tabItem {
                    Label("GitHub", systemImage: "person.3.fill")
                }
            
            MyRestAPIContainerView(viewModel: myRestAPIViewModel)
                            .tabItem {
                                Label("My API", systemImage: "tray.full.fill")
                            }
        }
    }
}
