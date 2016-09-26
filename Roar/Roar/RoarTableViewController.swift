//
//  RoarTableViewController.swift
//  Roar
//
//  Created by Pascal Sturmfels on 3/14/16.
//  Copyright © 2016 1AM. All rights reserved.
//
import CryptoSwift
import UIKit
import CoreData

class RoarTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    var ifCellRegistered: Bool = false
    
    var managedObjectContext: NSManagedObjectContext!
    var messageHashes: [String] {
        get {
            let messageObjects: [RoarMessageCore] = self.fetchedResultsController.fetchedObjects!
            return messageObjects.map({ (messageObject) -> String in
                return messageObject.messageHash!
            })
        }
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController<RoarMessageCore> = {
        // Initialize Fetch Request
        let fetchRequest: NSFetchRequest<RoarMessageCore> = NSFetchRequest<RoarMessageCore>(entityName: "RoarMessageCore")
        
        // Add Sort Descriptors
        let sortDescriptor: NSSortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Initialize Fetched Results Controller
        let fetchedResultsController: NSFetchedResultsController<RoarMessageCore> = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    override func viewDidLoad() {
        print("Attempting to create tableview")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        tableView.register(RoarTableViewCell.self, forCellReuseIdentifier: "RoarTableViewCell")
        
        print("Did add tableview to controller")
        
        //Reference the appDelegate to recover the managedObjectContext
        unowned let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        self.managedObjectContext = appDelegate.managedObjectContext
        
        //The following block of code defends against coreData migrations. 
        //When the coreData format is changed, the OS needs to migrate the store
        //to avoid crashes.
        let userDefaults: UserDefaults = UserDefaults.standard
        let didDetectIncompatibleStore: Bool = userDefaults.bool(forKey: "didDetectIncompatibleStore")
        
        if didDetectIncompatibleStore {
            // Show Alert
            let applicationName: Any? = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName")
            let message: String = "A serious application error occurred while \(applicationName) tried to read your data. Please contact support for help."
            
            self.showAlertWithTitle("Warning", message: message, cancelButtonTitle: "OK")
        }
        
        //Attempt to recover all the the persisted messages.
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError: NSError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
            
            let applicationName: Any? = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName")
            let message: String = "A serious application error occurred while \(applicationName) tried to read your data. Please contact support for help."
            
            self.showAlertWithTitle("Warning", message: message, cancelButtonTitle: "OK")
        }
        
        //Set up the tableView style
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
        self.tableView.separatorColor = UIColor.black
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.tableView.cellLayoutMarginsFollowReadableWidth = false
    }
    
    //MARK: tableViewControllerDelegate
    override func numberOfSections(in tableView: UITableView) -> Int {
        if let sections: [NSFetchedResultsSectionInfo] = fetchedResultsController.sections {
            return sections.count
        }
        return 0
    }
    
    //This function is part of UITableViewController's built-in classes.
    //It asks for the number of rows in tableView = number of messages = size of cellDataArray.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections: [NSFetchedResultsSectionInfo] = fetchedResultsController.sections {
            let sectionInfo: NSFetchedResultsSectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    
    //This function is part of UITableViewController's built-in classes.
    //In it, we tell the tableView which message to render at each index of the table.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Grab the appropriate data from our cellDataArray.
        
        let roarMessageCoreData: RoarMessageCore = fetchedResultsController.object(at: indexPath)
        let cell: RoarTableViewCell
        
        //Create a cell of type MCChatTableViewCell
        let reusableCell: AnyObject = tableView.dequeueReusableCell(withIdentifier: "RoarTableViewCell", for: indexPath)
        cell = reusableCell as! RoarTableViewCell
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        cell.layoutMargins = UIEdgeInsets.zero
        
        //Set the cell's width to be the width of the screen.
        cell.frame.size.width = self.tableView.frame.width
        
        //Set the cell's data to be the appropriate data.
        //Notice that in this line, MCChatTableViewCell's property, data, is set.
        //After it is set, the didSet keyword will be called, calling updateCellUI()
        cell.data = RoarMessage(message: roarMessageCoreData)
        
        return cell
    }
    
    //This function is part of UITableViewController's built-in classes.
    //In it, we determine the height of each cell in the tableView.
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //Notice that MCChatCellData already have a property called cellHeight
        //that depends on the size of the message.
        let roarMessageCoreData: RoarMessageCore = fetchedResultsController.object(at: indexPath)
        
        let roarMessageUI: RoarMessage = RoarMessage(message: roarMessageCoreData)
        
        return roarMessageUI.cellHeight
    }
    
    
    // MARK: Fetched Results Controller Delegate Methods
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break;
        case .delete:
             if let indexPath = indexPath {
             tableView.deleteRows(at: [indexPath], with: .fade)
             }
            break;
        case .update:
            abort()
            /*
             if let indexPath = indexPath {
             let cell = tableView.cellForRowAtIndexPath(indexPath) as! RoarTableViewCell
             let roarMessageCoreData = fetchedResultsController.objectAtIndexPath(indexPath) as! RoarMessageCore
             cell.data = RoarMessage(message: roarMessageCoreData)
             }
             */
            break;
        case .move:
            abort()
            /*
             if let indexPath = indexPath {
             tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
             }
             
             if let newIndexPath = newIndexPath {
             tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
             }*/
            break;
        }
    }
    
    func returnMessageArray(excludingHashes hashArray: [String]) -> [RoarMessageSentCore] {
        var messageArray: [RoarMessageSentCore] = [RoarMessageSentCore]()
        let messageObjects: [RoarMessageCore] = fetchedResultsController.fetchedObjects!
        
        for i in 0 ..< messageObjects.count {
            if !hashArray.contains(messageObjects[i].messageHash!) {
                messageArray.append(RoarMessageSentCore(message: messageObjects[i]))
            }
        }
        return messageArray
    }
    
    fileprivate func showAlertWithTitle(_ title: String, message: String, cancelButtonTitle: String) {
        // Initialize Alert Controller
        let alertController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Configure Alert Controller
        alertController.addAction(UIAlertAction(title: cancelButtonTitle, style: .default, handler: { (_) -> Void in
            let userDefaults: UserDefaults = UserDefaults.standard
            userDefaults.removeObject(forKey: "didDetectIncompatibleStore")
        }))
        
        // Present Alert Controller
        present(alertController, animated: true, completion: nil)
    }
    
    //WHENEVER YOU NEED TO ADD A MESSAGE TO THE TABLE, USE THIS FUNCTION.
    //An all-purpose function that adds a message to the table and updates the tableView.
    func addMessage(_ text: String, date: Date, user: String) {
        //Create a MCChatMessage object from the input parameters.
        
        let entity: NSEntityDescription? = NSEntityDescription.entity(forEntityName: "RoarMessageCore", in: self.managedObjectContext)
        let newRoarMessageCore: RoarMessageCore = NSManagedObject(entity: entity!, insertInto: self.managedObjectContext) as! RoarMessageCore
        newRoarMessageCore.text = text
        newRoarMessageCore.date = date
        newRoarMessageCore.user = user
        newRoarMessageCore.messageHash = text.sha1()
        
        do {
            try managedObjectContext.save()
        } catch {
            let fetchError: NSError = error as NSError
            print(fetchError)
            let applicationName: Any? = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName")
            let message = "A serious application error occurred while \(applicationName) tried to save your data. Please contact support for help."
            
            self.showAlertWithTitle("Warning", message: message, cancelButtonTitle: "OK")
        }
    }
}
