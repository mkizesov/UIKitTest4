//
//  ViewController.swift
//  UIKitTest4
//
//  Created by M K on 10.02.2024.
//

import UIKit


class ViewController: UIViewController, UITableViewDelegate {
    
    var tableView: UITableView!
    var dataSource: UITableViewDiffableDataSource<Int, DamnModel>!
    var snapshot = NSDiffableDataSourceSnapshot<Int, DamnModel>()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        tableView.delegate = self

        let actionButton = UIBarButtonItem(title: "Shuffle", style: .plain, target: self, action: #selector(shuffleItems))
        navigationItem.title = "UIKitTest4"
        navigationItem.rightBarButtonItems = [actionButton]
    }
    
    func setupView() {
        view.backgroundColor = .systemBackground
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.clipsToBounds = true
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor)
        ])
        
        configureDataSource()
    }
    
    func configureDataSource() {
        dataSource = UITableViewDiffableDataSource<Int, DamnModel>(tableView: tableView) {
            (tableView, indexPath, model) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = model.title
            cell.accessoryType = model.isSelected ? .checkmark : .none
            return cell
        }
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        snapshot.appendSections([0])
        let tableData = generateData(number: 35)
        snapshot.appendItems(tableData, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    @objc func shuffleItems() {
        let items = snapshot.itemIdentifiers.shuffled()
        snapshot.deleteAllItems()
        snapshot.appendSections([0])
        snapshot.appendItems(items, toSection: 0)
        snapshot.reconfigureItems(items)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedItem = dataSource.itemIdentifier(for: indexPath) else { return }

        if snapshot.sectionIdentifiers.contains(indexPath.section) {
            var updatedItem = snapshot.itemIdentifiers(inSection: indexPath.section).first(where: { $0.id == selectedItem.id })!
            updatedItem.isSelected = !selectedItem.isSelected
            
            if let index = snapshot.itemIdentifiers.firstIndex(where: { $0.id == selectedItem.id }) {
                snapshot.deleteItems([selectedItem])
                
                if (indexPath.min() == index) {
                    snapshot.insertItems([updatedItem], beforeItem: snapshot.itemIdentifiers[index])
                } else {
                    snapshot.insertItems([updatedItem], afterItem: snapshot.itemIdentifiers[index - 1])
                }
                dataSource.apply(snapshot, animatingDifferences: false)
                
                if (!selectedItem.isSelected) {
                    if let firstItem = snapshot.itemIdentifiers(inSection: indexPath.section).first, firstItem != updatedItem {
                        snapshot.moveItem(updatedItem, beforeItem: firstItem)
                        dataSource.apply(snapshot, animatingDifferences: true)
                    }
                }
            }
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
}

func generateData(number: Int) -> [DamnModel] {
    return (0..<number).map { DamnModel(id: $0, title: "\($0)", isSelected: false) }
}

struct DamnModel: Hashable {
    let id: Int
    let title: String
    var isSelected: Bool // Add this line
}
