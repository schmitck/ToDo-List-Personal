//
//  ViewController.swift
//  ToDo List
//
//  Created by Cooper Schmitz on 2/8/20.
//  Copyright © 2020 Cooper Schmitz. All rights reserved.
//THIS IS THE SOURCE OF THE DATA

import UIKit

class toDoListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    
    var toDoItems: [ToDoItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        loadData()
    }
    
    func loadData() {
        let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
              //to use again, the only thing you need to do is change "todos"
              let documentURL = directoryURL.appendingPathComponent("todos").appendingPathExtension("json")
        
        guard let data = try? Data(contentsOf: documentURL) else {
            return
        }
        let jsonDecoder = JSONDecoder()
        do {
            toDoItems = try jsonDecoder.decode(Array<ToDoItem>.self, from: data)
            tableView.reloadData()
        } catch {
            print("ERROR: Could not load data 😡 \(error.localizedDescription)")
        }
    }
    
    func saveData() {
        //going through the apps FileManager and using a URL
        //gives access to all the stuff on the file system
        //.userDomainMask is where the personal data is saved
        //by saying .first! you are getting the first element of the urls array
        let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        //to use again, the only thing you need to do is change "todos"
        let documentURL = directoryURL.appendingPathComponent("todos").appendingPathExtension("json")
        let jsonEncoder = JSONEncoder()
        //try? throws, meaning that if the method has an error, it will return nil
        let data = try? jsonEncoder.encode(toDoItems)
        do {
            //.noFileProtection allows file to overwrite any existing file
            try data?.write(to: documentURL, options: .noFileProtection)
        } catch {
            print("ERROR: Could not save data 😡 \(error.localizedDescription)")
        }
        //put this wherever data is changed
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            //this is where our segue is headed
        let destination = segue.destination as! ToDoDetailTableTableViewController
            //this is an OPTIONAL, but we are 100% that there is going to be a table view cell, which has a value
        let selectedIndexPath = tableView.indexPathForSelectedRow!
            destination.toDoItem = toDoItems[selectedIndexPath.row]
        } else {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: selectedIndexPath, animated: true)
            }
        }
    }
    @IBAction func unwindFromDetail(segue: UIStoryboardSegue) {
        let source = segue.source as! ToDoDetailTableTableViewController
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            toDoItems[selectedIndexPath.row] = source.toDoItem
            tableView.reloadRows(at: [selectedIndexPath], with: .automatic)
        } else {
            let newIndexPath = IndexPath(row: toDoItems.count, section: 0)
            toDoItems.append(source.toDoItem)
            tableView.insertRows(at: [newIndexPath], with: .bottom)
            tableView.scrollToRow(at: newIndexPath, at: .bottom, animated: true)
            }
            saveData()
        }
    
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        if tableView.isEditing {
            tableView.setEditing(false, animated: true)
                    sender.title = "Edit"
                    addBarButton.isEnabled = true
        } else {
            tableView.setEditing(true, animated: true)
            sender.title = "Done"
            addBarButton.isEnabled = false
        }
    }
}

extension toDoListViewController: UITableViewDelegate, UITableViewDataSource{
    //these functions are DEMANDED by the tableView
    //predefined funciton names can be option clicked on for their descriptions
    
    //tells the data source to return the number of rows in a given section of table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Number of rows in section is being called, returning \(toDoItems.count)")
        return toDoItems.count
    }
    //asks the data source (ToDoListViewController Code) for a cell to insert in a particular location in tableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cell for tow was just called for indexPath.row = \(indexPath.row) which is the cell containing \(toDoItems[indexPath.row])")
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = toDoItems[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            toDoItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            saveData()
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
         let itemToMove = toDoItems[sourceIndexPath.row]
        toDoItems.remove(at: sourceIndexPath.row)
        toDoItems.insert(itemToMove, at: destinationIndexPath.row)
        saveData()
    }
}
