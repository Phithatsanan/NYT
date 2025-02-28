// MyRestAPIContainerView.swift
import SwiftUI
import UIKit

struct MyRestAPIContainerView: UIViewControllerRepresentable {
    let viewModel: MyRestAPIViewModel
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let mainVC = MyRestAPIViewController(viewModel: viewModel)
        return UINavigationController(rootViewController: mainVC)
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // Usually nothing
    }
}
