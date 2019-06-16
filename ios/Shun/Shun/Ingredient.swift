import Foundation
import FirebaseFirestore

class Ingredient {

    var name: String
    var imageURLString: String

    init?(document: DocumentSnapshot) {
        guard let data = document.data() else {
            return nil
        }

        guard let name = data["name"] as? String else {
            return nil
        }

        guard let imageURLString = data["imageURLString"] as? String else {
            return nil
        }

        self.name = name
        self.imageURLString = imageURLString
    }
}
