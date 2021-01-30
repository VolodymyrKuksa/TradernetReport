//
//  Persistence.swift
//  Tradernet Report
//
//  Created by VolodymyrKuksa on 7/01/21.
//

import CoreData

struct PersistenceController {
    static var shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        let sampleKey = APIKey(context: viewContext)
        sampleKey.friendlyName = "Sample Key"
        sampleKey.publicKey = "my_public_key"
        sampleKey.secret = "my_secret"
        sampleKey.clientCode = "12345"
        sampleKey.clientName = "Volodymyr Kuksa"
        sampleKey.configs = BrokerReportConfigsEntity(context: viewContext)
        sampleKey.configs?.timeFrame = TimeFrameEntity(context: viewContext)
        
        let sampleKeyWithLargeName = APIKey(context: viewContext)
        sampleKeyWithLargeName.friendlyName = "This is an API Key with a real big name he he he he he he he he"
        sampleKeyWithLargeName.publicKey = "my_public_key"
        sampleKeyWithLargeName.secret = "my_secret"
        sampleKeyWithLargeName.clientCode = "12345"
        sampleKeyWithLargeName.clientName = "Volodymyr Kuksa"
        sampleKeyWithLargeName.configs = BrokerReportConfigsEntity(context: viewContext)
        sampleKeyWithLargeName.configs?.timeFrame = TimeFrameEntity(context: viewContext)
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    static var previewMany: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        for idx in 1...10 {
            let sampleKey = APIKey(context: viewContext)
            sampleKey.friendlyName = "Sample Key \(idx)"
            sampleKey.publicKey = "my_public_key \(idx)"
            sampleKey.secret = "my_secret \(idx)"
            sampleKey.clientCode = "12345"
            sampleKey.clientName = "Volodymyr Kuksa"
            sampleKey.configs = BrokerReportConfigsEntity(context: viewContext)
            sampleKey.configs?.timeFrame = TimeFrameEntity(context: viewContext)
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
    
    func saveContext() {
      let context = container.viewContext
      if context.hasChanges {
        do {
          try context.save()
        } catch {
          let nserror = error as NSError
          fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
      }
    }

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Tradernet_Report")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
}
