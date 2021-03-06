//
//  ToDoDetailTableTableViewController.swift
//  ToDo List
//
//  Created by Cooper Schmitz on 2/9/20.
//  Copyright © 2020 Cooper Schmitz. All rights reserved.
//

import UIKit
//CACHABLE DATEFORMATTER

private let dateFormatter: DateFormatter = {
    print("I just created a Date Formatter")
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .short
    return dateFormatter
}()


class ToDoDetailTableTableViewController: UITableViewController {
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var noteView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var reminderSwitch: UISwitch!
    @IBOutlet weak var dateLabel: UILabel!
    
    var toDoItem: ToDoItem!

    let datePickerIndexPath = IndexPath(row: 1, section: 1)
    let notesTextViewIndexPath = IndexPath(row: 0, section: 2)
    let notesRowHeight: CGFloat = 200
    let defaultRowHeight: CGFloat = 44
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if toDoItem == nil {
            toDoItem =  ToDoItem(name: "", date: Date().addingTimeInterval(24*60*60), notes: "", reminderSet: false,  completed: false)
            nameField.becomeFirstResponder()
        }
        //hide keyboard whenever tapped outside
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        nameField.delegate = self
        updateUserInterface()

    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        toDoItem = ToDoItem(name: nameField.text!, date: datePicker.date, notes: noteView.text, reminderSet: reminderSwitch.isOn, completed: toDoItem.completed )
    }
    
    func enableDisableSaveButton(text: String) {
        if text.count > 0 {
                  saveBarButton.isEnabled = true
              } else {
                  saveBarButton.isEnabled = false
              }
    }
    
    func updateUserInterface() {
        nameField.text = toDoItem.name
        datePicker.date = toDoItem.date
        noteView.text = toDoItem.notes
        reminderSwitch.isOn = toDoItem.reminderSet
        //TERNARY OPERATOR instead
        dateLabel.textColor = (reminderSwitch.isOn ? .black : .gray)
        dateLabel.text = dateFormatter.string(from: toDoItem.date)
        enableDisableSaveButton(text: nameField.text!)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        //MARK:- SOFTWARE LEGO - POP AND DISMISS 
        //the presenting view controller is the new navigation controller, this will give a Boolean
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode {
            dismiss(animated: true, completion: nil)
        } else {
            //this means that
        navigationController?.popViewController(animated: true)
        }
    }
    @IBAction func reminderSwitchChanged(_ sender: UISwitch) {
        self.view.endEditing(true)
        //TERNARY OPERATOR
    dateLabel.textColor = (reminderSwitch.isOn ? .black : .gray)
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
       self.view.endEditing(true)
        dateLabel.text = dateFormatter.string(from: sender.date)
    }
    
    
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        enableDisableSaveButton(text: sender.text!)
    }
    
    
}
extension ToDoDetailTableTableViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath {
        case datePickerIndexPath:
            return reminderSwitch.isOn ? datePicker.frame.height : 0
        case notesTextViewIndexPath:
            return notesRowHeight
        default:
            return defaultRowHeight
        }
    }
}

extension ToDoDetailTableTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        noteView.becomeFirstResponder()
        return true
    }
}
