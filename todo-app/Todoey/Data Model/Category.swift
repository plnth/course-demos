import Foundation
import RealmSwift

class Category: Object {
    
    @objc dynamic var name: String = ""
    @objc dynamic var colorHexString: String?
    
    var items = List<Item>()
}
