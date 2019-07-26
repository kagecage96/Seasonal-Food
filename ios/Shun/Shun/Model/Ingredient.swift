import Foundation
import FirebaseFirestore

class Ingredient {

    enum Category: String {
        case seafood = "seafood"
        case vegetable = "vegetable"
        case fruit = "fruit"
        case other = "other"
    }
    
    var name: String
    var imageURLString: String
    var category: Category
    var seasons: [Bool]
    var documentID: String

    init?(document: DocumentSnapshot) {
        guard let data = document.data() else {
            return nil
        }

        guard let name = data["name"] as? String else {
            return nil
        }

        guard let imageURLString = data["image_url"] as? String else {
            return nil
        }

        guard let category = Category(rawValue: data["category"] as? String ?? "others") else {
            return nil
        }

        guard let seasons = data["seasons"] as? [Bool] else {
            return nil
        }

        self.name = name
        self.imageURLString = imageURLString
        self.category = category
        self.seasons = seasons
        self.documentID = document.documentID
    }

    func isSeason(month: Int) -> Bool {
        return seasons[month-1]
    }
}
