//
//  ViewController.swift
//  FaceToName
//
//  Created by Alexander Kazakov on 4/18/19.
//  Copyright © 2019 Alexander Kazakov. All rights reserved.
//

import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

  var people = [Person]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
    
  }

  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return people.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell else {
      fatalError("Could not dequeue 'Person' cell.")
    }
    
    let person = people[indexPath.item]
    cell.name.text = person.name
    
    let imagePath = getDocumentsDirectory().appendingPathComponent(person.image)
    cell.imageView.image = UIImage(contentsOfFile: imagePath.path)
    
    cell.imageView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
    cell.imageView.layer.borderWidth = 2
    cell.imageView.layer.cornerRadius = 3
    cell.layer.cornerRadius = 7
    
    return cell
  }
  
  @objc func addNewPerson() {
    let picker = UIImagePickerController()
    picker.sourceType = .camera
    picker.allowsEditing = true
    picker.delegate = self
    present(picker, animated: true)
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    guard let image = info[.editedImage] as? UIImage else { return }
    
    let imageName = UUID().uuidString
    let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
    if let jpegData = image.jpegData(compressionQuality: 0.8) {
      do {
        try jpegData.write(to: imagePath)
      } catch {
        print("ERROR: unable to save image to disk: \(error)")
      }
      
      let person = Person(name: "Unknown", image: imageName)
      people.append(person)
      collectionView.reloadData()
    }
    
    dismiss(animated: true)
  }
  
  func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    let ac = UIAlertController(title: "Do you want to rename the person or delete them?", message: nil, preferredStyle: .actionSheet)
    ac.addAction(UIAlertAction(title: "Rename", style: .default) { [weak self] _ in
      self?.renamePersonAtIndex(index: indexPath)
    })
    ac.addAction(UIAlertAction(title: "Delete", style: .default) { [weak self] _ in
      self?.deletePersonAtIndex(index: indexPath)
    })
    present(ac, animated: true)
     
  }

  func renamePersonAtIndex(index: IndexPath) {
    let ac = UIAlertController(title: "Rename person", message: nil, preferredStyle: .alert)
    ac.addTextField()
    
    ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] (_) in
      let person = self?.people[index.item]
      guard let newName = ac?.textFields?[0].text else { return }
      person?.name = newName
      self?.collectionView.reloadData()
    })
    ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    present(ac, animated: true)
  }
  
  func deletePersonAtIndex(index: IndexPath) {
    let person = people[index.item]
    people.remove(at: index.item)
    
    do {
      try FileManager.default.removeItem(at: getDocumentsDirectory().appendingPathComponent(person.image))
    } catch {
      fatalError("Unable to remove image file for person: \(person.name)")
    }
      
    collectionView.reloadData()
  }
  
}

