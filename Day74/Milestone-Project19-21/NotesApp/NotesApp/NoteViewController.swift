//
//  NoteViewController.swift
//  NotesApp
//
//  Created by Alexander on 7/3/19.
//  Copyright © 2019 Alexander Kazakov. All rights reserved.
//

import UIKit

class NoteViewController: UIViewController {

  @IBOutlet weak var textView: UITextView!
  private let filename = "notes.json"
  var note: Note?
  var existingNoteID: String?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationController?.navigationBar.prefersLargeTitles = false
    existingNoteID = note?.id
    textView.text = note?.content
    
    // Navigation Bar Items
    navigationItem.setRightBarButtonItems([
      UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveNote))
    ], animated: true)
  }

  @objc func saveNote() {
    var notes = [Note]()
    
    // Check if there is any data in the note, RETURN if empty.
    if textView.text.isEmpty { return }
    
    // Save textView content to Note instance (either existing, if editing or create a new one, if new button was pressed)
    if let note = note {
      note.content = textView.text
    } else {
      note = Note(content: textView.text)
    }
    
    // If other notes exist, retrieve them from file
    if Storage.fileExists(filename, in: .documents) {
      do {
        notes = try Storage.retrieve(filename, from: .documents, as: [Note].self)
        // If editing an existing Note find it's ID within the list to modify it istead of creating a new one
        if let existingNoteID = existingNoteID {
          let existingNoteIndex = notes.firstIndex(where: { $0.id == existingNoteID })
          if existingNoteIndex != nil { notes.remove(at: existingNoteIndex!) }
        }
      } catch {
        print(error)
        // Remove file, if unable to read from it
        Storage.remove(filename, from: .documents)
      }
    }
    
    // Prepend the new note to the beginning of the list
    notes.insert(note!, at: 0)
    
    // Save to file
    Storage.store(notes, to: .documents, as: filename)
    
    // Go back to list of notes
    navigationController?.popViewController(animated: true)
  }
  
}
