import Foundation
import RealmSwift

class Item: Object {
    
    @objc dynamic var title: String = ""
    @objc dynamic var isDone: Bool = false
    @objc dynamic var dateCreated: Date = Date()
    
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
