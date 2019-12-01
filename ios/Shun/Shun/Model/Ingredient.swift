import Foundation
import FirebaseFirestore

class Ingredient {
    var name: String
    var imageURLString: String
    var seasons: [Bool]
    var documentID: String
    var subCategory: String
    var subCategoryNameJP: String
    var category: String
    var localLocationName: String

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

        guard let subCategory = data["sub_category"] as? String else {
            return nil
        }

        guard let subCategoryJP = data["sub_category_name_jp"] as? String else {
            return nil
        }

        guard let category = data["category"] as? String else {
            return nil
        }


        guard let seasons = data["seasons"] as? [Bool] else {
            return nil
        }
        
        guard let localLocationName = data["local_location_name"] as? String else {
            return nil
        }

        self.name = name
        self.imageURLString = imageURLString
        self.category = category
        self.seasons = seasons
        self.documentID = document.documentID
        self.subCategory = subCategory
        self.subCategoryNameJP = subCategoryJP
        self.localLocationName = localLocationName
    }

    func isSeason(month: Int) -> Bool {
        return seasons[month-1]
    }
}
