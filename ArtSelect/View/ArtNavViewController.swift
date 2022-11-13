//
//  ViewController.swift
//  ArtSelect
//
//  Created by Kelly Camacho on 5/4/22.
//

import UIKit
import CoreData

class ArtNavViewController: UIViewController {
    @IBOutlet weak var NewCanvasButton: UIButton!
    @IBOutlet weak var CollectionButton: UIButton!
    
    var managedObjectContext: NSManagedObjectContext!

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
    }
    
    override func prepare(
        for segue: UIStoryboardSegue,
        sender: Any?
    ) {
        //New Canvas
        if segue.identifier == "toCanvas" {
            let controller = segue.destination as! CanvasViewController
            controller.managedObjectContext = managedObjectContext
        }
        
        //Gallery
        if segue.identifier == "toGallery" {
            let controller = segue.destination as! GalleryViewController
            controller.managedObjectContext = managedObjectContext
        }
    }

}

