import Foundation
import FirebaseFirestore

class Article {
    var subArticles: [SubArticle] = []
    var title: String

    init?(document: DocumentSnapshot) {
        guard let data = document.data() else {
            return nil
        }

        guard let title = data["title"] as? String else {
            return nil
        }

        self.title = title
    }
}
