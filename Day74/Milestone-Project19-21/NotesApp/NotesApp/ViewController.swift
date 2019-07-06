//
//  ViewController.swift
//  NotesApp
//
//  Created by Alexander Kazakov on 7/2/19.
//  Copyright © 2019 Alexander Kazakov. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

  private let tableCellID = "noteCell"
  private let filename = "notes.json"
  private var notes = [Note]()
  private var countWithActivityIndicator = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
  
  //MARK: - View Lifecycle Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.allowsMultipleSelectionDuringEditing = true
    
    loadNotes()
    
    // Navigation Items
    title = "Notes"
    navigationController?.navigationBar.tintColor = UIColor(red: 0.82, green: 0.69, blue: 0.17, alpha:1.0)
    navigationController?.toolbar.tintColor = navigationController?.navigationBar.tintColor
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editTableItems))
    
    // Toolbar Items
    navigationController?.isToolbarHidden = false
    countWithActivityIndicator = UIBarButtonItem(title: "\(notes.count) Notes", style: .plain, target: nil, action: nil)
    countWithActivityIndicator.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)], for: .normal)
    countWithActivityIndicator.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)], for: .disabled)
    countWithActivityIndicator.tintColor = .black
    countWithActivityIndicator.isEnabled = false
    
    setToolbarItems([
      UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
      countWithActivityIndicator,
      UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
      UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(createNewNote))
    ], animated: true)
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    navigationController?.navigationBar.prefersLargeTitles = true
    loadNotes()
    countWithActivityIndicator.title = "\(notes.count) Notes"
    tableView.reloadData()
  }
  
  // Load Notes from filesystem
  fileprivate func loadNotes() {
    if Storage.fileExists(filename, in: .documents) {
      do {
        notes = try Storage.retrieve(filename, from: .documents, as: [Note].self)
        tableView.reloadData()
      } catch {
        print(error)
      }
    }
  }

  //MARK: - Actions
  
  @objc func editTableItems() {
    tableView.setEditing(!tableView.isEditing, animated: true)
    
    var currentToolbarItems = toolbarItems!
    
    if tableView.isEditing {
      // Change Navigation Bar Button
      navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(editTableItems))
      
      // Change Toolbar Button
      let deleteButton = UIBarButtonItem(title: "Delete", style: .done, target: self, action: #selector(deleteNotes))
      deleteButton.tintColor = .red
      
      currentToolbarItems[currentToolbarItems.endIndex - 1] = deleteButton
      setToolbarItems(currentToolbarItems, animated: true)
    } else {
      navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editTableItems))
      
      // Change Toolbar Button
      currentToolbarItems[currentToolbarItems.endIndex - 1] = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(createNewNote))
      setToolbarItems(currentToolbarItems, animated: true)
    }
  }

  @objc func createNewNote() {
    if let vc = storyboard?.instantiateViewController(withIdentifier: "NoteDetails") {
      navigationController?.pushViewController(vc, animated: true)
    }
  }
  
  @objc func deleteNotes() {
    if let selectedIndexPaths = tableView.indexPathsForSelectedRows {
      for indexPath in selectedIndexPaths {
        notes.remove(at: indexPath.row)
      }
      tableView.deleteRows(at: selectedIndexPaths, with: .left)
      Storage.store(notes, to: .documents, as: filename)
      editTableItems()
    }
  }
  
  //MARK: - TableView Methods
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return notes.count
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    if !tableView.isEditing {
      if let noteDetailVC = storyboard?.instantiateViewController(withIdentifier: "NoteDetails") as? NoteViewController {
        noteDetailVC.note = notes[indexPath.row]
        navigationController?.pushViewController(noteDetailVC, animated: true)
      }
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: tableCellID)
    cell?.textLabel?.text = notes[indexPath.row].content
    return cell ?? UITableViewCell()
  }
  
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      notes.remove(at: indexPath.row)
      tableView.deleteRows(at: [indexPath], with: .left)
      Storage.store(notes, to: .documents, as: filename)
    }
  }
  
}

