//
//  Canvas+CoreDataClass.swift
//  ArtSelect
//
//  Created by Kelly Camacho on 5/6/22.
//  Source: Textbook
//

import Foundation
import CoreData
import UIKit

@objc(Canvas)
public class Canvas: NSManagedObject {
    var hasCanvas: Bool {
        return canvasID != nil
    }
    
    var canvasURL: URL {
        assert(canvasID != nil, "No canvas ID set")
        let filename = "Canvas-\(canvasID!.intValue).jpg"
        return applicationDocumentsDirectory.appendingPathComponent(filename)
    }
    
    var canvasImage: UIImage? {
        return UIImage(contentsOfFile: canvasURL.path)
    }
    
    class func nextCanvasID() -> Int {
        let userDefaults = UserDefaults.standard
        let currentID = userDefaults.integer(forKey: "CanvasID") + 1
        userDefaults.set(currentID, forKey: "CanvasID")
        return currentID
    }
    
    func removeCanvasFile() {
        if hasCanvas {
            do {
                try FileManager.default.removeItem(at: canvasURL)
            } catch {
                print("Error removing file: \(error)")
            }
        }
    }
    
}
