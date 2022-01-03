//
//  Persistence.swift
//  Tradernet Report
//
//  Created by VolodymyrKuksa on 7/01/21.
//

import CoreData

struct PersistenceController {
    static var shared = PersistenceController()
    
    private func createSampleAPIKey(name: String = "Sample Key",
                                    publicKey: String = "sample_public_key",
                                    secret: String = "sample_secret",
                                    clientCode: String = "12345",
                                    clientName: String = "James Smith"
    ) -> APIKey {
        let sampleKey = APIKey(context: container.viewContext)
        sampleKey.friendlyName = name
        sampleKey.publicKey = publicKey
        sampleKey.secret = secret
        sampleKey.clientCode = clientCode
        sampleKey.clientName = clientName
        sampleKey.configs = BrokerReportConfigsData(context: container.viewContext)
        sampleKey.configs!.downloadURL = "~/Downloads/"
        sampleKey.configs!.timeFrame = TimeFrameData(context: container.viewContext)
        sampleKey.configs!.timeFrame?.isSingleDay = false;
        sampleKey.configs!.timeFrame!.isDaily = true;
        sampleKey.configs!.timeFrame!.selectedDay = Date()
        sampleKey.configs!.timeFrame!.dateStart = Date()
        sampleKey.configs!.timeFrame!.dateEnd = Date()
        return sampleKey
    }

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        let sampleKey = result.createSampleAPIKey()
        let sampleKeyWithLargeName = result.createSampleAPIKey(name: "This is an API Key with a real big name he he he he he he he he")
        
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
            let sampleKey = result.createSampleAPIKey(name: "Sample Key \(idx)")
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
