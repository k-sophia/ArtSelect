//
//  CollectionViewController.swift
//  ArtSelect
//
//  Created by Kelly Camacho on 5/4/22.
//  Source : Textbook

import UIKit
import CoreData

class GalleryViewController: UITableViewController {
    var managedObjectContext: NSManagedObjectContext!
    
    lazy var fetchedResultsController: NSFetchedResultsController<Canvas> = {
        let fetchRequest = NSFetchRequest<Canvas>()
        
        let entity = Canvas.entity()
        fetchRequest.entity = entity
        
        let sort1 = NSSortDescriptor(key: "category", ascending: true)
        let sort2 = NSSortDescriptor(key: "canvasTitle", ascending: true)
        fetchRequest.sortDescriptors = [sort1, sort2]

        fetchRequest.fetchBatchSize = 20
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.managedObjectContext,
            sectionNameKeyPath: "category",
            cacheName: "Canvas")
        
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        let textAttributes = [NSAttributedString.Key.foregroundColor:
                                UIColor(red: 251/255, green: 233/255, blue: 215/255, alpha: 1)]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationBar.barTintColor = UIColor(red: 17/255, green: 38/255, blue: 62/255, alpha: 1)
        
        performFetch()
        navigationItem.rightBarButtonItem = editButtonItem
        
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditCanvas" {
            let controller = segue.destination  as! CanvasDetailsViewController
            controller.managedObjectContext = managedObjectContext

            if let indexPath = tableView.indexPath(
                for: sender as! UITableViewCell
            ) {
                let canvas = fetchedResultsController.object(at: indexPath)
                controller.CanvasToEdit = canvas
            }
        }
    }
    
    @IBAction func cancel() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Table View Delegates
    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "CanvasCell",
            for: indexPath) as! CanvasCell
        let canvas = fetchedResultsController.object(at: indexPath)
        cell.configure(for: canvas)
        return cell
    }
    
    override func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ){
        if editingStyle == .delete {
            let canvas = fetchedResultsController.object(at: indexPath)
            managedObjectContext.delete(canvas)
            canvas.removeCanvasFile()
            
            do {
                try managedObjectContext.save()
            } catch {
                fatalCoreDataError(error)
            }
        }
    }
    
    override func numberOfSections(
        in tableView: UITableView
    ) -> Int {
        return fetchedResultsController.sections!.count
    }
    
    override func tableView(
        _ tableView: UITableView,
        titleForHeaderInSection section: Int
    ) -> String? {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.name
    }
    
    // MARK: - Helper methods
    func performFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalCoreDataError(error)
        }
    }
    
    deinit {
        fetchedResultsController.delegate = nil
    }
}


// MARK: - NSFetchedResultsController Delegate Extension
extension GalleryViewController:NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>
    ){
        print("*** controllerWillChangeContent")
        tableView.beginUpdates()
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ){
        switch type { case .insert:
            print("*** NSFetchedResultsChangeInsert (object)")
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            
        case .delete:
            print("*** NSFetchedResultsChangeDelete (object)")
            tableView.deleteRows(at: [indexPath!], with: .fade)
            
        case .update:
            print("*** NSFetchedResultsChangeUpdate (object)")
            if let cell = tableView.cellForRow(
                at: indexPath!) as? CanvasCell {
                let location = controller.object(
                    at: indexPath!) as! Canvas
                cell.configure(for: location)
            }
            
        case .move:
            print("*** NSFetchedResultsChangeMove (object)")
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            
        @unknown default:
            print("*** NSFetchedResults unknown type")
        }
    }

    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange sectionInfo: NSFetchedResultsSectionInfo,
        atSectionIndex sectionIndex: Int,
        for type: NSFetchedResultsChangeType
    ){
        switch type {
            case .insert:
                print("*** NSFetchedResultsChangeInsert (section)")
                tableView.insertSections(
                    IndexSet(integer: sectionIndex), with: .fade)
            
            case .delete:
                print("*** NSFetchedResultsChangeDelete (section)")
                tableView.deleteSections(
                    IndexSet(integer: sectionIndex), with: .fade)

            case .update:
                print("*** NSFetchedResultsChangeUpdate (section)")

            case .move:
                print("*** NSFetchedResultsChangeMove (section)")

            @unknown default:
                print("*** NSFetchedResults unknown type")
        }
    }

    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>
    ){
        print("*** controllerDidChangeContent")
        tableView.endUpdates()
    }
}
