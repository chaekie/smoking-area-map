//
//  MySpot+CoreDataProperties.swift
//  SmokingAreaMap
//
//  Created by chaekie on 7/17/24.
//
//

import Foundation
import CoreData


extension MySpot {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MySpot> {
        return NSFetchRequest<MySpot>(entityName: "MySpot")
    }

    @NSManaged public var address: String
    @NSManaged public var longitude: Double
    @NSManaged public var latitude: Double
    @NSManaged public var name: String
    @NSManaged public var createdAt: Date?
    @NSManaged public var photo: Data?
    @NSManaged public var id: UUID?

    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일"
        guard let createdAt else { return "" }
        let newDateString = formatter.string(from: createdAt)
        return newDateString

    }

}

extension MySpot : Identifiable {

}
