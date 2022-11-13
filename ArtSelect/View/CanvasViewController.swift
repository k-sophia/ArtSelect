//
//  Canvas.swift
//  ArtSelect
//
//  Created by Kelly Camacho on 5/4/22.
//

import UIKit
import CoreData

protocol CanvasViewControllerDelegate: AnyObject {
    func EditedCanvas (
        _ canvasViewController: CanvasViewController
    )
}

class CanvasViewController: UIViewController {
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var tempImageView: UIImageView!
    @IBOutlet weak var brushButton: UIButton!
    @IBOutlet weak var eraserButton: UIButton!
    @IBOutlet weak var navView: UIView!
    
    var lastPoint = CGPoint.zero
    var color = UIColor.black
    var brushStroke: CGFloat = 10.0
    var opacity: CGFloat = 1.0
    var swiped = false
    var emptyCanvas = UIImage(named: "emptyCanvas")
    var selectIMG: UIImage? = nil
    var editCanvas = false
    
    var managedObjectContext: NSManagedObjectContext!
    weak var delegate: CanvasViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        brushButton.isSelected = true
        
        if selectIMG != nil {
            mainImageView.image = selectIMG
            selectIMG = nil
        }
        else {
            mainImageView.image = emptyCanvas
        }
    }
    
    // MARK: - Navigation
    override func prepare(
        for segue: UIStoryboardSegue,
        sender: Any?
    ) {
        //Select IMG
        if segue.identifier == "imageSelect" {
            let controller = segue.destination as! ImageViewController
            controller.delegate = self
            controller.managedObjectContext = managedObjectContext
        }
        
        //Settings - Brush
        if segue.identifier == "toBrushSetting" {
            guard
                let navController = segue.destination as? UINavigationController,
                let settingsController = navController.topViewController as? SettingsViewController
            else {
                return
            }
            
            settingsController.delegate = self
            settingsController.stroke = brushStroke
            settingsController.opacity = opacity
            
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            color.getRed(&red, green: &green, blue: &blue, alpha: nil)
            settingsController.red = red
            settingsController.green = green
            settingsController.blue = blue
        }
    }
    
    @IBAction func cancel() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Pressed Button
    
    @IBAction func toolPressed(_ sender: Any) {
        if navView.isHidden == true {
            navView.isHidden = false
        }
        else {
            navView.isHidden = true
        }
    }
    
    @IBAction func resetPressed(_ sender: Any) {
        mainImageView.image = emptyCanvas
    }
    
    @IBAction func brushPressed() {
        brushButton.isSelected = true
        eraserButton.isSelected = false
        
        color = .black
        opacity = 1.0
    }
    
    @IBAction func eraserPressed() {
        brushButton.isSelected = false
        eraserButton.isSelected = true
        
        color = .white
        opacity = 1.0
    }
    
    @IBAction func savePressed(_ sender: Any) {
        if editCanvas == true {
            delegate?.EditedCanvas(self)
            navigationController?.popViewController(animated: true)
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "CanvasDetail") as! CanvasDetailsViewController
            vc.managedObjectContext = managedObjectContext
            vc.image = mainImageView.image
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: - Draw
    //Source : https://www.raywenderlich.com/5895-uikit-drawing-tutorial-how-to-make-a-simple-drawing-app 
    
    override func touchesBegan(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {
        guard let touch = touches.first else {
            return
        }
        swiped = false
        lastPoint = touch.location(in: view)
    }
    
    func drawLine(
        from fromPoint: CGPoint,
        to toPoint: CGPoint
    ) {
        UIGraphicsBeginImageContext(view.frame.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        tempImageView.image?.draw(in: view.bounds)
        
        context.move(to: fromPoint)
        context.addLine(to: toPoint)
      
        context.setLineCap(.round)
        context.setBlendMode(.normal)
        context.setLineWidth(brushStroke)
        context.setStrokeColor(color.cgColor)
      
        context.strokePath()
      
        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.alpha = opacity
        UIGraphicsEndImageContext()
    }

    override func touchesMoved(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {
        guard let touch = touches.first else {
            return
        }

        swiped = true
        let currentPoint = touch.location(in: view)
        drawLine(from: lastPoint, to: currentPoint)
        
        lastPoint = currentPoint
    }

    override func touchesEnded(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {
        if !swiped {
        // draw a single point
            drawLine(from: lastPoint, to: lastPoint)
        }
        
        merge()
    }
    
    func merge() {
        // Merge tempImageView into mainImageView
        UIGraphicsBeginImageContext(mainImageView.frame.size)
        mainImageView.image?.draw(in: view.bounds, blendMode: .normal, alpha: 1.0)
        tempImageView?.image?.draw(in: view.bounds, blendMode: .normal, alpha: opacity)
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        tempImageView.image = nil
    }
    
}

// MARK: - SettingsViewControllerDelegate
extension CanvasViewController: SettingsViewControllerDelegate {
    func settingsViewControllerFinished(
        _ settingsViewController: SettingsViewController
    ) {
        brushStroke = settingsViewController.stroke
        opacity = settingsViewController.opacity
        color = UIColor(red: settingsViewController.red,
                        green: settingsViewController.green,
                        blue: settingsViewController.blue,
                        alpha: opacity)

        dismiss(animated: true)
    }
}

// MARK: - ImageViewControllerDelegate
extension CanvasViewController: ImagesViewControllerDelegate {
    func ImageIsSelected(
        _ imagesViewController: ImageViewController
    ) {
        let tempOpacity: CGFloat = opacity
        opacity = 1.0
        
        tempImageView.contentMode = UIView.ContentMode.scaleAspectFill
        tempImageView.image = imagesViewController.selectIMG
        
        merge()
        
        selectIMG = nil
        opacity = tempOpacity
        dismiss(animated: true)
    }
}

