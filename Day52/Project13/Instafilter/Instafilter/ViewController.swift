//
//  ViewController.swift
//  Instafilter
//
//  Created by Alexander Kazakov on 5/2/19.
//  Copyright © 2019 Alexander Kazakov. All rights reserved.
//

import CoreImage
import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var intensity: UISlider!
  @IBOutlet weak var changeFilterButton: UIButton!
  var currentImage: UIImage!
  
  var context: CIContext!
  var currentFilter: CIFilter!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  
    title = "Instafilter"
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importPicture))
    
    context = CIContext()
    currentFilter = CIFilter(name: "CISepiaTone")
  }
  
  @objc func importPicture() {
    let picker = UIImagePickerController()
    picker.allowsEditing = true
    picker.delegate = self
    
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      picker.sourceType = .camera
    } else {
      picker.sourceType = .photoLibrary
    }
    
    present(picker, animated: true)
  }

  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    var image: UIImage!
    
    if let pickedImage = info[.editedImage] as? UIImage {
      image = pickedImage
    } else if let pickerImage = info[.originalImage] as? UIImage {
      image = pickerImage
    } else {
        print("ERROR: No image found in imagePicker arguments.")
        return
    }
    
    dismiss(animated: true)
    
    currentImage = image
    
    let beginImage = CIImage(image: currentImage)
    currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
    applyProcessing()
  }
  
  @IBAction func changeFilter(_ sender: UIButton) {
    let ac = UIAlertController(title: "Choose Filter", message: nil, preferredStyle: .actionSheet)
    
    ac.addAction((UIAlertAction(title: "CIBumpDistortion", style: .default, handler: setFilter)))
    ac.addAction((UIAlertAction(title: "CIGaussianBlur", style: .default, handler: setFilter)))
    ac.addAction((UIAlertAction(title: "CIPixellate", style: .default, handler: setFilter)))
    ac.addAction((UIAlertAction(title: "CISepiaTone", style: .default, handler: setFilter)))
    ac.addAction((UIAlertAction(title: "CITwirlDistortion", style: .default, handler: setFilter)))
    ac.addAction((UIAlertAction(title: "CIUnsharpMask", style: .default, handler: setFilter)))
    ac.addAction((UIAlertAction(title: "CIVignette", style: .default, handler: setFilter)))
    ac.addAction((UIAlertAction(title: "Cancel", style: .cancel, handler: nil)))
    
    if let popoverController = ac.popoverPresentationController {
      popoverController.sourceView = sender
      popoverController.sourceRect = sender.bounds
    }
    
    present(ac, animated: true)
  }
  
  func setFilter(action: UIAlertAction) {
    guard currentImage != nil else { showMessage(title: "No Image Selected!", message: "Please select an image first."); return }
    guard let actionTitle = action.title else { return }
    
    currentFilter = CIFilter(name: actionTitle)
    
    changeFilterButton.setTitle(actionTitle, for: .normal)
    
    guard let beginImage = CIImage(image: currentImage) else {
      print("Unable to convert UIImage to CIImage")
      return
    }
    
    currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
    applyProcessing()
  }
  
  @IBAction func save(_ sender: Any) {
    guard let image = imageView.image else { showMessage(title: "No Image Selected!", message: "Please select an image first."); return }
    UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
  }
  
  func showMessage(title: String, message: String, notification: Bool = true) {
    let vc = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    if notification {
      vc.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
    }
    
    present(vc, animated: true)
  }
  
  @IBAction func intensityChanged(_ sender: Any) {
    applyProcessing()
  }
  
  func applyProcessing() {
    let inputKeys = currentFilter.inputKeys
    
    if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey) }
    if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(intensity.value * 200, forKey: kCIInputRadiusKey) }
    if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(intensity.value * 10, forKey: kCIInputScaleKey) }
    if inputKeys.contains(kCIInputCenterKey) { currentFilter.setValue(CIVector(x: currentImage.size.width / 2, y: currentImage.size.height / 2), forKey: kCIInputCenterKey) }
    
    guard let outputImage = currentFilter.outputImage else { return }
    
    if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
      let processedImage = UIImage(cgImage: cgImage)
      imageView.image = processedImage
    }
  }
  
  @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
    let ac: UIAlertController!
    
    if let error = error {
      ac = UIAlertController(title: "Save Error", message: error.localizedDescription, preferredStyle: .alert)
      ac.addAction(UIAlertAction(title: "OK", style: .default))
    } else {
      ac = UIAlertController(title: "Saved!", message: "Your altered image was saved to your photos.", preferredStyle: .alert)
      ac.addAction(UIAlertAction(title: "OK", style: .default))
    }
    present(ac, animated: true)
  }
}


