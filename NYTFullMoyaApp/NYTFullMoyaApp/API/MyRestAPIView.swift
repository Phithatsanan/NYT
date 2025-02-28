import UIKit

final class MyRestAPIViewController: UIViewController {
    
    private let viewModel: MyRestAPIViewModel
    
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

        tableView.rowHeight = 70
        tableView.separatorStyle = .singleLine
        tableView.showsVerticalScrollIndicator = false
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Add",
            style: .plain,
            target: self,
            action: #selector(onAddTapped)
        )

        // Load initial data
        Task {
            await viewModel.loadItems()
            tableView.reloadData()
        }

        // 🔴 Listen for WebSocket Updates
        NotificationCenter.default.addObserver(self, selector: #selector(updateTableView), name: .dataUpdated, object: nil)
    }

    @objc private func updateTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    @objc private func onAddTapped() {
        let addVC = AddItemViewController { [weak self] name, desc in
            guard let self = self else { return }
            Task {
                await self.viewModel.createItem(name: name, description: desc)
            }
        }
        let nav = UINavigationController(rootViewController: addVC)
        present(nav, animated: true)
    }
}

extension MyRestAPIViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        
        let item = viewModel.items[indexPath.row]
        
        content.text = item.name
        content.secondaryText = item.description
        content.image = UIImage(systemName: "tray.full")
        content.textProperties.font = .systemFont(ofSize: 20, weight: .semibold)
        content.secondaryTextProperties.font = .systemFont(ofSize: 16, weight: .regular)
        
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = viewModel.items[indexPath.row]
        let editVC = EditItemViewController(item: item) { [weak self] newName, newDesc in
            guard let self = self else { return }
            Task {
                await self.viewModel.updateItem(id: item.id, name: newName, description: newDesc)
            }
        }
        navigationController?.pushViewController(editVC, animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
        -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            guard let self = self else { return }
            let item = self.viewModel.items[indexPath.row]
            Task {
                await self.viewModel.deleteItem(id: item.id)
                completion(true)
            }
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
