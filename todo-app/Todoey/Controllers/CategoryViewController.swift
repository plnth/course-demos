import UIKit
import RealmSwift
import SwipeCellKit
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {

    let realm = try! Realm()
    var categories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.backgroundColor = UIColor(hexString: "1D9BF6")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        guard let category = categories?[indexPath.row] else { return UITableViewCell() }
        
        cell.textLabel?.text = category.name
        if let hexString = category.colorHexString {
            cell.backgroundColor = UIColor(hexString: hexString)
        } else {
            let newColor = UIColor.randomFlat()
            cell.backgroundColor = newColor
            cell.textLabel?.textColor = ContrastColorOf(newColor, returnFlat: true)
            
            do {
                try realm.write {
                    category.colorHexString = newColor.hexValue()
                }
            } catch {
                debugPrint(error)
            }
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    func loadCategories() {
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    func save(category: Category) {

        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            debugPrint(error)
        }
        
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        guard let categoryToDelete = categories?[indexPath.row] else { return }
        
        do {
            try realm.write {
                realm.delete(categoryToDelete)
            }
        } catch {
            debugPrint(error)
        }
    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        var tf = UITextField()
        
        let action = UIAlertAction(title: "Add category", style: .default) { [weak self] _ in

            let newCategory = Category()
            newCategory.name = tf.text ?? "Empty category"
            
            self?.save(category: newCategory)
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new category"
            tf = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? TodoListViewController else { return }
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
}
