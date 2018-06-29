//
//  CategoryViewController.swift
//  Todo-App
//
//  Created by Kabelo Mashishi on 2018/06/29.
//  Copyright © 2018 Kabelo Mashishi. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    var categoryArray = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //load categories
        loadCategories()
    }
    
    //MARK: - tableView datasource methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categoryArray[indexPath.row].name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray[indexPath.row]
        }
    }
    

    //MARK: - Data manipulation methods
    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
        do {
            try categoryArray = context.fetch(request)
        } catch {
            print("Error loading categories: \(error)")
        }
        
        tableView.reloadData()
    }
    
    func saveCategory() {
        do {
            try context.save()
        } catch {
            print("Error saving category: \(error)")
        }
        
        tableView.reloadData()
    }
    
    //MARK: - Add new categories
    
     @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var catTextField :UITextField = UITextField()
        
        let alertCtrl = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) {
            (alertAction) in
            let category = Category(context: self.context);
            category.name = catTextField.text
            
            self.categoryArray.append(category)
            self.saveCategory()
        }
        
        alertCtrl.addAction(action)
        alertCtrl.addTextField {
            (textField) in
            textField.placeholder = "Add new category.."
            catTextField = textField
        }
        
        present(alertCtrl, animated: true, completion: nil)
     }
    
}
