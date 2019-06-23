import Foundation
import FirebaseFirestore

class SubArticle {
    var contents: [String]
    var title: String

    init?(document: DocumentSnapshot) {
        guard let data = document.data() else {
            return nil
        }

        guard let contents = data["contents"] as? [String] else {
            return nil
        }

        guard let title = data["title"] as? String else {
            return nil
        }

        self.contents = contents
        self.title = title
    }
}
