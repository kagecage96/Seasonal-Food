import Foundation
import FirebaseFirestore

class Ingredient {
    var name: String
    var imageURLString: String
    var seasons: [Bool]
    var documentID: String
    var subCategoryID: String
    var locations: [String]

    init?(document: DocumentSnapshot) {
        guard let data = document.data() else {
            return nil
        }
        
        let nameField = Configuration.shared.language.name + "_name"

        guard let name = data[nameField] as? String else {
            return nil
        }

        guard let imageURLString = data["image_url"] as? String else {
            return nil
        }

        guard let seasons = data["seasons"] as? [Bool] else {
            return nil
        }
        
        guard let locations = data["locations"] as? [String] else {
            return nil
        }
        
        guard let subCategoryID = data["sub_category_id"] as? String else {
            return nil
        }

        self.name = name
        self.imageURLString = imageURLString
        self.seasons = seasons
        self.documentID = document.documentID
        self.subCategoryID = subCategoryID
        self.locations = locations
    }

    func isSeason(month: Int) -> Bool {
        return seasons[month-1]
    }
}
