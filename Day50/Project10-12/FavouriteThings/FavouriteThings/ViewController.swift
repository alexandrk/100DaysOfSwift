//
//  ViewController.swift
//  FavouriteThings
//
//  Created by Alexander Kazakov on 4/27/19.
//  Copyright © 2019 Alexander Kazakov. All rights reserved.
//

import UIKit

class ViewController: UICollectionViewController {

  var things = [Thing]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Favourite Things"
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItem))
    
    // Restore values (if any from UserDefaults)
    if let savedThings = UserDefaults.standard.object(forKey: "things") as? Data {
      let jsonDecoder = JSONDecoder()
      
      do {
        things = try jsonDecoder.decode([Thing].self, from: savedThings)
      } catch {
        print("Failed to load things. Error: ", error
        )
      }
    }
  }

  @objc func addItem() {
    let vc = UIImagePickerController()
    vc.allowsEditing = true
    vc.delegate = self
    
    // Give preference to camera (if available)
    if  UIImagePickerController.isSourceTypeAvailable(.camera) {
      vc.sourceType = .camera
    } else {
      vc.sourceType = .photoLibrary
    }
    
    present(vc, animated: true)
    
  }
  
}

extension ViewController: UINavigationControllerDelegate { }

extension ViewController: UIImagePickerControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    
    guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
      print("Could not load image from UIImagePicker")
      return
    }
    
    // Save image to documents dirtectory
    let filename = saveImage(image: image)
    
    dismiss(animated: true) { [weak self] in
      self?.nameAThing(filename: filename)
    }
  }
  
  func nameAThing(filename: String) {
    let vc = UIAlertController(title: "Please name the thing:", message: nil, preferredStyle: .alert)
    vc.addTextField { (textField) in
      textField.placeholder = "Name"
    }
    vc.addTextField { (textField) in
      textField.placeholder = "Description (Optional)"
    }
    
    vc.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self] (_) in
      guard let name = vc.textFields?[0].text else { print("Please specify things' name"); return }
      
      let thing = Thing(name: name, description: vc.textFields?[1].text, filename: filename)
      self?.things.append(thing)
      self?.saveToMemory(self?.things)
      self?.collectionView.reloadData()
    }))
    
    present(vc, animated: true)
  }
  
  func saveToMemory(_ things: [Thing]?) {
    guard let things = things else { return }
    
    let jsonEncoder = JSONEncoder()
    if let savedData = try? jsonEncoder.encode(things) {
      let defaults = UserDefaults.standard
      defaults.set(savedData, forKey: "things")
    } else {
      print("Failed to save people.")
    }
  }
  
  /***
   Attempts to save image to filesystem.
    Returns: - filename
  */
  func saveImage(image: UIImage) -> String {
    let filename = UUID().uuidString
    let documentsDirectory = HelperFuncs.getDocumentsDirectory()
    let imageData = image.jpegData(compressionQuality: 0.8)
    
    do {
      try imageData?.write(to: documentsDirectory.appendingPathComponent(filename))
    } catch {
      fatalError("Unable to write UIImage to documents directory path: \(error)")
    }
    return filename
  }
}

extension ViewController {
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThingCell", for: indexPath) as! ThingCell
    
    cell.thing = things[indexPath.item]
    
    return cell
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return things.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let vc = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { fatalError("Unable to instantiate DetailViewController") }
    
    let thing = things[indexPath.item]
    vc.thing = thing
    navigationController?.pushViewController(vc, animated: true)
  }
}

