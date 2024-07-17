//
//  PersistenceController.swift
//  SmokingAreaMap
//
//  Created by chaekie on 7/15/24.
//

import CoreData

class PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "CoreData")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { description, error in
            if let error {
                dump(SAError(.CoreDataSettingError, description: error.localizedDescription))
                fatalError()
            }
        }
    }

    func saveChanges() {
        let context = container.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                dump(SAError(.CoreDataSaveError))
            }
        }
    }

    func create(name: String, address: String) {
        let entity = Spot(context: container.viewContext)
        entity.id = UUID()
        entity.name = name
        entity.address = address
        entity.createdAt = Date()
        saveChanges()
    }

    func read() -> [Spot] {
        var results: [Spot] = []
        let request = NSFetchRequest<Spot>(entityName: "Spot")
        let sort = NSSortDescriptor(key: "createdAt", ascending: false)
        request.sortDescriptors = [sort]

        do {
            results = try container.viewContext.fetch(request)
        } catch {
            dump(SAError(.CoreDateFetchError))
        }

        return results
    }

    func update(entity: Spot, name: String? = nil, address: String? = nil) {
        var hasChanges: Bool = false

        if name != nil {
            entity.name = name
            hasChanges = true
        }
        if address != nil {
            entity.address = address
            hasChanges = true
        }

        if hasChanges {
            saveChanges()
        }
    }

    func delete(_ entity: Spot) {
        container.viewContext.delete(entity)
        saveChanges()
    }

}

