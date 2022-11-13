//
//  Canvas+CoreDataProperties.swift
//  ArtSelect
//
//  Created by Kelly Camacho on 5/6/22.
//
//

import Foundation
import CoreData


extension Canvas {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Canvas> {
        return NSFetchRequest<Canvas>(entityName: "Canvas")
    }

    @NSManaged public var canvasTitle: String
    @NSManaged public var canvasDescription: String
    @NSManaged public var category: String
    @NSManaged public var canvasID: NSNumber?

}

extension Canvas : Identifiable {

}
