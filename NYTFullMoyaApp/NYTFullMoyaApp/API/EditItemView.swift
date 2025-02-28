// EditItemViewController.swift
import UIKit

final class EditItemViewController: UIViewController {
    
    private let item: ItemResponse
    private let onSave: (String, String) -> Void
    
    private let nameField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        return tf
    }()
    
    private let descriptionField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        return tf
    }()
    
    init(item: ItemResponse, onSave: @escaping (String, String) -> Void) {
        self.item = item
        self.onSave = onSave
        super.init(nibName: nil, bundle: nil)
        self.title = "Edit Item"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        nameField.text = item.name
        descriptionField.text = item.description
        
        let stack = UIStackView(arrangedSubviews: [nameField, descriptionField])
        stack.axis = .vertical
        stack.spacing = 12
        
        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancel", style: .plain,
            target: self, action: #selector(onCancel)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Save", style: .done,
            target: self, action: #selector(onSaveTapped)
        )
    }
    
    @objc private func onCancel() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func onSaveTapped() {
        guard let name = nameField.text, !name.isEmpty,
              let desc = descriptionField.text, !desc.isEmpty else {
            showAlert(title: "Missing Information", message: "Please fill in both fields before saving.")
            return
        }
        
        // Call the onSave callback to update the ViewModel
        onSave(name, desc)
        
        // Use pop instead of dismiss for a pushed navigation stack
        navigationController?.popViewController(animated: true)
    }


    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
}
