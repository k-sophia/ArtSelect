//
//  CanvasDetailsViewController.swift
//  ArtSelect
//
//  Created by Kelly Camacho on 5/6/22.
//

import UIKit
import CoreData
import AudioToolbox

class CanvasDetailsViewController: UITableViewController {
    @IBOutlet var canvasView: UIImageView!
    @IBOutlet var titleTextView: UITextView!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var categoryLabel: UILabel!
    
    var image: UIImage?
    var titleText = "Untitled"
    var notesText = "No Notes"
    var categoryName = "No Category"
    var soundID: SystemSoundID = 0
    
    var managedObjectContext: NSManagedObjectContext!
    
    var CanvasToEdit: Canvas? {
        didSet {
            if let canvas = CanvasToEdit {
                titleText = canvas.canvasTitle
                notesText = canvas.canvasDescription
                categoryName = canvas.category
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSoundEffect("Done.wav")
        overrideUserInterfaceStyle = .dark
        let textAttributes = [NSAttributedString.Key.foregroundColor:
                                UIColor(red: 251/255, green: 233/255, blue: 215/255, alpha: 1)]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationBar.barTintColor = UIColor(red: 17/255, green: 38/255, blue: 62/255, alpha: 1)
        
        descriptionTextView.textContainer.maximumNumberOfLines = 5
        descriptionTextView.backgroundColor = .white
        titleTextView.textContainer.maximumNumberOfLines = 1
        titleTextView.backgroundColor = .white
        
        
        
        if let canvas = CanvasToEdit {
            title = "Edit Canvas"
            if let theImage = canvas.canvasImage {
                canvasView.image = theImage
            }
        } else {
            canvasView.image = image
        }
        
        categoryLabel.text = categoryName
        titleTextView.text = titleText
        descriptionTextView.text = notesText
        
        // Hide keyboard
        let gestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(hideKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickCategory" {
            let controller = segue.destination as! CategoryPickerViewController
            controller.selectedCategoryName = categoryName
        }
    }
    
    @IBAction func categoryPickerDidPickCategory(
        _ segue: UIStoryboardSegue
    ){
        let controller = segue.source as! CategoryPickerViewController
        categoryName = controller.selectedCategoryName
        categoryLabel.text = categoryName
    }
    
  
    // MARK: - Actions
    // Source : Textbook
    @IBAction func done() {
        guard let mainView = navigationController?.parent?.view
            else { return }
        
        let hudView = HudView.hud(inView: mainView, animated: true)
        let canvas: Canvas
        
        if let temp = CanvasToEdit {
            hudView.text = "Updated"
            canvas = temp
        } else {
            hudView.text = "Saved"
            canvas = Canvas(context: managedObjectContext)
            canvas.canvasID = nil
        }

        canvas.canvasTitle = titleTextView.text
        canvas.canvasDescription = descriptionTextView.text
        canvas.category = categoryName
        
        // Save image
        if let image = image {
            if !canvas.hasCanvas {
                canvas.canvasID = Canvas.nextCanvasID() as NSNumber
            }
            
            if let data = image.jpegData(compressionQuality: 0.5) {
                do {
                    try data.write(to: canvas.canvasURL, options: .atomic)
                } catch {
                    print("Error writing file: \(error)")
                }
            }
        }
          
        do {
            try managedObjectContext.save()
            self.playSoundEffect()
            afterDelay(1) {
                hudView.hide()
                self.navigationController?.popViewController(animated: true)
            }
        } catch {
            fatalCoreDataError(error)
        }
    }
  
    @IBAction func cancel() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sharePressed(_ sender: Any) {
        guard let image = canvasView.image else {
            return
        }
        let activity = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activity, animated: true)
    }
    
    @IBAction func editPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Canvas") as! CanvasViewController
        vc.delegate = self
        vc.editCanvas = true
        vc.selectIMG = canvasView.image
        vc.managedObjectContext = managedObjectContext
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @objc func hideKeyboard(
        _ gestureRecognizer: UIGestureRecognizer
    ){
        let point = gestureRecognizer.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        if indexPath != nil && indexPath!.section == 0 &&
            indexPath!.row == 0 {
            return
        }
        descriptionTextView.resignFirstResponder()
    }
    
    // MARK: - Table View Delegates
    override func tableView(
        _ tableView: UITableView,
        willSelectRowAt indexPath: IndexPath
    ) -> IndexPath? {
        if indexPath.section == 0 || indexPath.section == 1 {
            return indexPath
        } else {
            return nil
        }
    }
    
    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ){
        if indexPath.section == 0 && indexPath.row == 0 {
            descriptionTextView.becomeFirstResponder()
        }
    }
    
    // MARK: - Sound effects
    // Source : Textbook
    func loadSoundEffect(_ name: String) {
        if let path = Bundle.main.path(forResource: name, ofType: nil) {
            let fileURL = URL(fileURLWithPath: path, isDirectory: false)
            let error = AudioServicesCreateSystemSoundID(fileURL as CFURL, &soundID)
            if error != kAudioServicesNoError {
                print("Error code \(error) loading sound: \(path)")
            }
        }
    }
    
    func unloadSoundEffect() {
        AudioServicesDisposeSystemSoundID(soundID)
        soundID = 0
    }
    
    func playSoundEffect() {
        AudioServicesPlaySystemSound(soundID)
    }
}

// MARK: - CanvasViewControllerDelegate
extension CanvasDetailsViewController: CanvasViewControllerDelegate {
    func EditedCanvas (
        _ canvasViewController: CanvasViewController
    ) {
        canvasView.image = canvasViewController.mainImageView.image
        image = canvasViewController.mainImageView.image
        managedObjectContext = canvasViewController.managedObjectContext
        dismiss(animated: true)
    }
}
