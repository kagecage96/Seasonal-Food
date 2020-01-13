import Foundation
import FirebaseFirestore

class SubCategory {
    var name: String
    var documentID: String
    
    init?(document: DocumentSnapshot) {
        guard let data = document.data() else {
            return nil
        }
        
        let nameField = Configuration.shared.language.name + "_name"
        
        guard let name = data[nameField] as? String else {
            return nil
        }
        
        self.name = name
        self.documentID = document.documentID
    }
}
