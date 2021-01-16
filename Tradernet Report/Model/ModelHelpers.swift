//
//  ModelHelpers.swift
//  Tradernet Report
//
//  Created by VolodymyrKuksa on 7/01/21.
//

import Foundation
import CoreData

func fetchAPIKeys(_ controller: PersistenceController = .preview) -> [APIKey] {
    let context = controller.container.viewContext
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "APIKey")
    let results = try! context.fetch(request) as! [APIKey]
    
    return results.sorted { $0.id < $1.id }
}
