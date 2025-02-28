// MyRestAPIViewController.swift
import UIKit

final class MyRestAPIViewController: UIViewController {
    
    private let viewModel: MyRestAPIViewModel
    
    // A fancier table style
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    init(viewModel: MyRestAPIViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.title = "My REST API"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        // Some advanced tweaks
        tableView.rowHeight = 70
        tableView.separatorStyle = .singleLine
        tableView.showsVerticalScrollIndicator = false
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // Register a basic UITableViewCell (we'll configure it more advanced below)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        // Layout
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        // "Add" button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Add",
            style: .plain,
            target: self,
            action: #selector(onAddTapped)
        )

        // Load items from the ViewModel
        Task {
            await viewModel.loadItems()
            tableView.reloadData()
            
            if let error = viewModel.errorMessage {
                print("Error: \(error)")
            }
        }
    }

    @objc private func onAddTapped() {
        let addVC = AddItemViewController { [weak self] name, desc in
            guard let self = self else { return }
            Task {
                await self.viewModel.createItem(name: name, description: desc)
                self.tableView.reloadData()
            }
        }
        
        let nav = UINavigationController(rootViewController: addVC)
        present(nav, animated: true)
    }
}

extension MyRestAPIViewController: UITableViewDataSource, UITableViewDelegate {
    // How many rows?
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.items.count
    }
    
    // Build each cell with a more modern UIListContentConfiguration
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        
        let item = viewModel.items[indexPath.row]
        
        content.text = item.name
        content.secondaryText = item.description
        
        // Just an SF Symbol for fun:
        content.image = UIImage(systemName: "tray.full")
        
        // Make the text bigger:
        content.textProperties.font = .systemFont(ofSize: 20, weight: .semibold)
        content.secondaryTextProperties.font = .systemFont(ofSize: 16, weight: .regular)
        
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    // Tap => Edit
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = viewModel.items[indexPath.row]
        
        let editVC = EditItemViewController(item: item) { [weak self] newName, newDesc in
            guard let self = self else { return }
            Task {
                await self.viewModel.updateItem(id: item.id, name: newName, description: newDesc)
                self.tableView.reloadData()
            }
        }
        navigationController?.pushViewController(editVC, animated: true)
    }
    
    // Swipe to delete
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
        -> UISwipeActionsConfiguration? {
            
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {
            [weak self] _, _, completion in
            guard let self = self else { return }
            let item = self.viewModel.items[indexPath.row]
            Task {
                await self.viewModel.deleteItem(id: item.id)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                completion(true)
            }
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
