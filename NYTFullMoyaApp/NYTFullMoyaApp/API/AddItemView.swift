// AddItemViewController.swift
import UIKit

final class AddItemViewController: UIViewController {
    
    // We'll call this closure when the user taps Save
    private let onAdd: (String, String) -> Void
    
    private let nameField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Name"
        tf.borderStyle = .roundedRect
        return tf
    }()
    
    private let descriptionField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Description"
        tf.borderStyle = .roundedRect
        return tf
    }()
    
    init(onAdd: @escaping (String, String) -> Void) {
        self.onAdd = onAdd
        super.init(nibName: nil, bundle: nil)
        self.title = "Add Item"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
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
            target: self, action: #selector(onSave)
        )
    }
    
    @objc private func onCancel() {
        dismiss(animated: true)
    }

    @objc private func onSave() {
        guard let name = nameField.text, !name.isEmpty,
              let desc = descriptionField.text, !desc.isEmpty else {
            showAlert(title: "Missing Information", message: "Please fill in both fields before saving.")
            return
        }
        
        onAdd(name, desc)
        dismiss(animated: true)
    }

    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }

}
