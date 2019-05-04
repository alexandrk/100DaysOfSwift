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
  @IBOutlet weak var intensitySlider: UISlider!
  @IBOutlet weak var radiusSlider: UISlider!
  @IBOutlet weak var centerXSlider: UISlider!
  @IBOutlet weak var centerYSlider: UISlider!
  @IBOutlet weak var scaleSlider: UISlider!
  @IBOutlet weak var angleSlider: UISlider!
  
  @IBOutlet weak var intensitySliderView: UIStackView!
  @IBOutlet weak var radiusSliderView: UIStackView!
  @IBOutlet weak var centerSliderView: UIStackView!
  
  @IBOutlet weak var centerXMaxLabel: UILabel!
  @IBOutlet weak var centerYMaxLabel: UILabel!
  
  @IBOutlet weak var angleSliderView: UIStackView!
  @IBOutlet weak var scaleSliderView: UIStackView!
  
  @IBOutlet weak var changeFilterButton: UIButton!
  @IBOutlet weak var saveButton: UIButton!
  
  var currentImage: UIImage!
  
  var context: CIContext!
  var currentFilter: CIFilter!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  
    title = "Instafilter"
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importPicture))
    
    if imageView.image == nil {
      intensitySliderView.isHidden = true
      radiusSliderView.isHidden = true
      centerSliderView.isHidden = true
      angleSliderView.isHidden = true
      scaleSliderView.isHidden = true
    }
    
    context = CIContext()
  }
  
  /***
   UIBarButtonItem handler for load picture
   */
  @objc func importPicture(_ sender: UIBarButtonItem) {
    
    let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      ac.addAction(UIAlertAction(title: "Camera", style: .default, handler: showPicker))
    }
    ac.addAction(UIAlertAction(title: "Gallery", style: .default, handler: showPicker))
    ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    
    if let popoverController = ac.popoverPresentationController {
      popoverController.barButtonItem = sender
    }
    
    present(ac, animated: true)
  }

  /***
   Call Image picker from UIBarButtonItem handler
   */
  func showPicker(_ action: UIAlertAction) {
    guard let actionTitle = action.title else { return }
    
    let sourceType: UIImagePickerController.SourceType = (actionTitle == "Camera") ? .camera : .photoLibrary
    let picker = UIImagePickerController()
    picker.allowsEditing = true
    picker.delegate = self
    picker.sourceType = sourceType
    
    present(picker, animated: true)
  }
  
  /***
   ImagePicker handler
  */
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
    imageView.image = currentImage
    
    resetSlidersSelectedValues()
    setSlidersValuesBasedOnImageDimensions(image)
  }
  
  /***
   Sets sliders values to 0 when new image is loaded or new filter is selected.
   */
  func resetSlidersSelectedValues() {
    intensitySlider.value = 0
    radiusSlider.value = 0
    centerXSlider.value = 0
    centerYSlider.value = 0
    scaleSlider.value = 0
    angleSlider.value = 0
  }
  
  /***
   Sets max values for sliders based on image dimensions in imageView
   */
  fileprivate func setSlidersValuesBasedOnImageDimensions(_ image: UIImage) {
    let xScale = image.size.width / imageView.bounds.width
    let yScale = image.size.height / imageView.bounds.height
    
    let coeff = max(xScale, yScale)
    
    centerXSlider.maximumValue = Float(image.size.width / coeff)
    centerYSlider.maximumValue = Float(image.size.height / coeff)
    centerXMaxLabel.text = "\(Int(centerXSlider.maximumValue))"
    centerYMaxLabel.text = "\(Int(centerYSlider.maximumValue))"
    
    radiusSlider.maximumValue = centerXSlider.maximumValue
  }
  
  /***
   Change Filter button press handler.
  */
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
  
  /***
   Filter Selection Handler
  */
  func setFilter(action: UIAlertAction) {
    resetSlidersSelectedValues()
    
    if currentImage == nil { showMessage(title: "No Image Selected!", message: "Please select an image first."); return }
    
    guard let actionTitle = action.title else { return }
    currentFilter = CIFilter(name: actionTitle)
    
    changeFilterButton.setTitle(actionTitle, for: .normal)
    
    guard let beginImage = CIImage(image: currentImage) else {
      print("Unable to convert UIImage to CIImage")
      return
    }
    
    currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
    
    setActiveSliders()
    
    applyProcessing()
  }
  
  func setActiveSliders() {
    let filterKeys = currentFilter.inputKeys.compactMap { $0.lowercased() }.joined(separator: ",")
    
    // Intensity
    intensitySliderView.isHidden = !filterKeys.contains("intensity")
    intensitySlider.isEnabled = !intensitySliderView.isHidden
    
    //Radius
    radiusSliderView.isHidden = !filterKeys.contains("radius")
    radiusSlider.isEnabled = !radiusSliderView.isHidden
    
    // Center
    centerSliderView.isHidden = !filterKeys.contains("center")
    centerXSlider.isEnabled = !centerSliderView.isHidden
    centerYSlider.isEnabled = !centerSliderView.isHidden
    
    //Scale
    scaleSliderView.isHidden = !filterKeys.contains("scale")
    scaleSlider.isEnabled = !scaleSliderView.isHidden
    
    // Angle
    angleSliderView.isHidden = !filterKeys.contains("angle")
    angleSlider.isEnabled = !angleSliderView.isHidden
    
  }
  
  func applyProcessing(slider: UISlider? = nil) {
    let inputKeys = currentFilter.inputKeys
    
    if inputKeys.contains(kCIInputIntensityKey) {
      currentFilter.setValue(intensitySlider.value, forKey: kCIInputIntensityKey)
    }
    if inputKeys.contains(kCIInputRadiusKey) {
      currentFilter.setValue(radiusSlider.value, forKey: kCIInputRadiusKey)
    }
    if inputKeys.contains(kCIInputScaleKey) {
      currentFilter.setValue(scaleSlider.value, forKey: kCIInputScaleKey)
    }
    if inputKeys.contains(kCIInputCenterKey) {
      currentFilter.setValue(CIVector(x: CGFloat(centerXSlider!.value * 2), y: CGFloat(centerYSlider!.value * 2)), forKey: kCIInputCenterKey)
    }
    if inputKeys.contains(kCIInputAngleKey) {
      currentFilter.setValue(NSNumber(value: angleSlider.value), forKey: kCIInputAngleKey)
    }
    
    guard let outputImage = currentFilter.outputImage else { return }
    
    if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
      let processedImage = UIImage(cgImage: cgImage)
      imageView.image = processedImage
    }
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
  
  @IBAction func sliderChanged(_ sender: UISlider) {
    applyProcessing(slider: sender)
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


