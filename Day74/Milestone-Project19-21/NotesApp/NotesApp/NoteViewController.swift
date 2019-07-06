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
  var notes = [Note]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Controller Setup
    navigationController?.navigationBar.prefersLargeTitles = false
    existingNoteID = note?.id
    textView.text = note?.content
    populateNotesArray()
    
    // Keyboard Adjustments
    let notificationCenter = NotificationCenter.default
    notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    
    // Navigation Bar Items
    navigationItem.setRightBarButtonItems([
      UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareNoteAction))
    ], animated: true)
    
    // Toolbar Items
    navigationController?.isToolbarHidden = false
    setToolbarItems([
      UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteNoteAction)),
      UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
      UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(createNewNoteAction))
      ], animated: true)
  
    // Saving edits on willResignActive event
    notificationCenter.addObserver(self, selector: #selector(applicationWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
    
  }

  override func viewWillDisappear(_ animated: Bool) {
    saveNote()
  }
  
  @objc func applicationWillResignActive() {
    saveNote()
  }
  
  @objc func shareNoteAction() {
    let vc = UIActivityViewController(activityItems: [textView.text ?? ""], applicationActivities: [])
    vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
    present(vc, animated: true)
  }
  
  @objc func deleteNoteAction() {
    deleteExistingNote()
    navigationController?.popViewController(animated: true)
  }
  
  @objc func createNewNoteAction() {
    saveNote()
    note = nil
    existingNoteID = nil
    textView.text = ""
  }
  
  private func deleteExistingNote() {
    if let existingNoteID = existingNoteID {
      removeNoteFromNotes(noteID: existingNoteID)
      Storage.store(notes, to: .documents, as: filename)
    }
  }
  
  fileprivate func populateNotesArray() {
    if notes.isEmpty {
      if Storage.fileExists(filename, in: .documents) {
        do {
          notes = try Storage.retrieve(filename, from: .documents, as: [Note].self)
        } catch {
          print(error)
          // Remove file, if unable to read from it
          Storage.remove(filename, from: .documents)
        }
      }
    }
  }
  
  fileprivate func removeNoteFromNotes(noteID: String) {
    let existingNoteIndex = notes.firstIndex(where: { $0.id == noteID })
    if existingNoteIndex != nil { notes.remove(at: existingNoteIndex!) }
  }
  
  func saveNote() {
    // Check if there is any data in the note, RETURN if empty.
    if textView.text.isEmpty { return }
    
    // Save textView content to Note instance (either existing, if editing or create a new one, if new button was pressed)
    if let note = note {
      note.content = textView.text
    } else {
      note = Note(content: textView.text)
    }
    
    // If editing an existing Note find it's ID within the list to modify it istead of creating a new one
    deleteExistingNote()
    
    // Prepend the new note to the beginning of the list
    notes.insert(note!, at: 0)
    
    // Assign note's ID to existing ID after a new note is created and saved,
    // so the deletion of the note works properly on next save, and doesn't duplicate the note
    existingNoteID = note?.id
    
    // Save to file
    Storage.store(notes, to: .documents, as: filename)
  }
  
  @objc func adjustForKeyboard(notification: Notification) {
    guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
    
    let keyboardScreenEndFrame = keyboardValue.cgRectValue
    let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
    
    if notification.name == UIResponder.keyboardWillHideNotification {
      textView.contentInset = .zero
    } else {
      textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
    }
    
    textView.scrollIndicatorInsets = textView.contentInset
    
    let selectedRange = textView.selectedRange
    textView.scrollRangeToVisible(selectedRange)
  }
  
}
