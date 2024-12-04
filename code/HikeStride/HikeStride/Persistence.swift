//
//  Persistence.swift
//  HikeStride
//
//  Created by Janindu Dissanayake on 2024-06-07.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<2 {
            let newDestination = HikingDestination(context: viewContext)
            newDestination.name = "Sample Trail"
            newDestination.location = "Sample Location"
            newDestination.difficulty = 5
            newDestination.type = "Loop"
            newDestination.info = "Sample Trail in Sample Mountain National Park offers breathtaking panoramic views as it winds through the alpine tundra, reaching elevations over 12,000 feet."
            newDestination.latitude = 37.7749
            newDestination.longitude = -122.4194
            newDestination.isFinished = false
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "HikeModel")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
}
