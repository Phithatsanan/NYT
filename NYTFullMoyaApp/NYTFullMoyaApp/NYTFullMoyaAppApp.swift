// NYTFullMoyaAppApp.swift
import SwiftUI

@main
struct NYTFullMoyaAppApp: App {
    // 1) Create dependencies at the top level (the “composition root”)
    private let service: MyAPIServiceProtocol
    private let repository: MyAPIRepositoryProtocol
    private let viewModel: MyRestAPIViewModel
    
    init() {
        // 2) Wire them up
        self.service = MyAPIService()                  // Moya-based service
        self.repository = MyAPIRepository(service: service)
        self.viewModel = MyRestAPIViewModel(repository: repository)
    }
    
    var body: some Scene {
        WindowGroup {
            // 3) Pass the VM to the tab view
            MainTabView(myRestAPIViewModel: viewModel)
        }
    }
}
