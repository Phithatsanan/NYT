import SwiftUI

@main
struct NYTFullMoyaAppApp: App {
    var body: some Scene {
        WindowGroup {
            // A tab-based root or your advanced Home. Choose one:
            // 1) If you want the multi-tab approach:
            MainTabView()

            // 2) If you ONLY want the advanced "Home" with horizontal carousels:
            // MainHomeView()
        }
    }
}
