//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {

    let realm = try! Realm()
    var todoItems: Results<Item>?
    
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
        if let colorString = selectedCategory?.colorHexString {
            guard let navBar = navigationController?.navigationBar,
            let color = UIColor(hexString: colorString) else { return }
            
            
            let contrastColor = ContrastColorOf(color, returnFlat: true)
            
            title = selectedCategory!.name
            navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : contrastColor]
            
            searchBar.barTintColor = color
            navBar.tintColor = contrastColor
            
            if #available(iOS 13, *) {
                navBar.backgroundColor = color
            } else {
                navBar.barTintColor = color
            }
        }
        tableView.rowHeight = 80
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {

        var tf = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { [weak self] _ in

            guard let `self` = self,
                let currentCategory = self.selectedCategory else { return }
            
            do {
                try self.realm.write {
                    let newItem = Item()
                    newItem.title = tf.text ?? "Empty item"
                    newItem.isDone = false
                    newItem.dateCreated = Date()
                    currentCategory.items.append(newItem)
                }
            } catch {
                debugPrint(error)
            }
            
            self.tableView.reloadData()
        }


        alert.addTextField { alertTextfield in
            alertTextfield.placeholder = "Create new item"
            tf = alertTextfield
        }

        alert.addAction(action)

        present(alert, animated: true, completion: nil)
    }
    
    func loadItems() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        guard let itemToDelete = todoItems?[indexPath.row] else { return }
        
        do {
            try realm.write {
                realm.delete(itemToDelete)
            }
        } catch {
            debugPrint(error)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            if todoItems?.isEmpty != true {
                let percentage = CGFloat(indexPath.row) / CGFloat(todoItems!.count)
                if let colorString = selectedCategory?.colorHexString, let color = UIColor(hexString: colorString)?.darken(byPercentage: percentage) {
                    cell.backgroundColor = color
                    cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
                }
            }
            cell.accessoryType = item.isDone ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let selectedItem = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    selectedItem.isDone.toggle()
                }
            } catch {
                debugPrint(error)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
}

//MARK: - UISearchBarDelegate
extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else { return }
        todoItems = todoItems?.filter(NSPredicate(format: "title CONTAINS[cd] %@", text)).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let text = searchBar.text, text.isEmpty {
            loadItems()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
