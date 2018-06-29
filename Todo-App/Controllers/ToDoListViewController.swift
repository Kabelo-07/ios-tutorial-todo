//
//  ViewController.swift
//  Todo-App
//
//  Created by Kabelo Mashishi on 2018/06/15.
//  Copyright © 2018 Kabelo Mashishi. All rights reserved.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {

    //var itemArray = ["Watch game of thrones", "What Spain v Portugal", "Attend School"]
    
    var itemArray = [Item]()
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("items.plist")
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext;

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print(dataFilePath!)
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        //removed as it's set inside did set closure??
        //loadItems()
        
        // Do any additional setup after loading the view, typically from a nib.
       // if let items = defaults.array(forKey: "ToDoListItems") as? [Item] {
        //    itemArray = items
       // }
    }
    
    //MARK - TableView Datasource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        let item = itemArray[indexPath.row];
        
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark: .none
        return cell
    }
    
    //MARK -Tableview delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        self.saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK - Add new items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var itemTextField: UITextField = UITextField()
        
        let alert = UIAlertController(title: "add new item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) {
            (action) in
            
            let item = Item(context: self.context)
            item.title = itemTextField.text!
            item.parentCategory = self.selectedCategory
            self.itemArray.append(item)
            
            self.saveItems()
        }
        
        alert.addAction(action)
        alert.addTextField { (alertText) in
            alertText.placeholder = "add new item"
            itemTextField = alertText
        }
        present(alert, animated: true, completion: nil)
    }
    
    func saveItems() {
        //let encoder = PropertyListEncoder()
        do {
            //let data = try encoder.encode(itemArray)
            try context.save()
            //try data.write(to: dataFilePath!)
        } catch {
            print("Error encoding item array \(error)")
        }
        
        tableView.reloadData()
    }
    
   /* func loadItems() {
        do {
            let data = try Data(contentsOf: dataFilePath!)
            let decoder = PropertyListDecoder()
            itemArray = try decoder.decode([Item].self, from: data)
        } catch {
            print("error loading data items \(error)")
        }
    }*/
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        do {
            
            let catPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", (selectedCategory?.name)!)
            if let additionalPredicate = predicate {
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [catPredicate, additionalPredicate])
            } else {
                request.predicate = catPredicate
            }
            
            itemArray = try context.fetch(request);
        } catch {
            print("error occured fetching data \(error)")
        }
        
        tableView.reloadData()
    }
    
}

extension ToDoListViewController: UISearchBarDelegate {
  
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request, predicate: predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count == 0 {
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

