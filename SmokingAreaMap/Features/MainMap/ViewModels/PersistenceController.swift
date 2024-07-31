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
        container = NSPersistentContainer(name: "MySpot")

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

    func create(name: String,
                address: String,
                longitude: Double,
                latitude: Double,
                photo: Data?) {
        let entity = MySpot(context: container.viewContext)
        entity.id = UUID()
        entity.createdAt = Date()
        entity.name = name
        entity.address = address
        entity.longitude = longitude
        entity.latitude = latitude
        entity.photo = photo
        saveChanges()
    }

    func read() -> [MySpot] {
        var results: [MySpot] = []
        let request = NSFetchRequest<MySpot>(entityName: "MySpot")
        let sort = NSSortDescriptor(key: "createdAt", ascending: false)
        request.sortDescriptors = [sort]

        do {
            results = try container.viewContext.fetch(request)
        } catch {
            dump(SAError(.CoreDateFetchError))
        }

        return results
    }

    func update(entity: MySpot,
                name: String? = nil,
                address: String? = nil,
                longitude: Double? = nil,
                latitude: Double? = nil,
                photo: Data? = nil) {
        var hasChanges: Bool = false

        if let name {
            entity.name = name
            hasChanges = true
        }
        
        if let address {
            entity.address = address
            hasChanges = true
        }

        if let longitude {
            entity.longitude = longitude
            hasChanges = true
        }

        if let latitude {
            entity.latitude = latitude
            hasChanges = true
        }

        if photo != Data() {
            entity.photo = photo
            hasChanges = true
        }

        if hasChanges {
            saveChanges()
        }
    }

    func delete(_ entity: MySpot) {
        container.viewContext.delete(entity)
        saveChanges()
    }

}

