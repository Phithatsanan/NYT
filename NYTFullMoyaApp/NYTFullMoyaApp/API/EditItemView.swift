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
        guard let newName = nameField.text, !newName.isEmpty,
              let newDesc = descriptionField.text, !newDesc.isEmpty else {
            return
        }
        onSave(newName, newDesc)
        navigationController?.popViewController(animated: true)
    }
}
