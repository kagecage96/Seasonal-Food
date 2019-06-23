import UIKit
import Firebase
import SDWebImage

class IngredientViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var tableViewConstraint: NSLayoutConstraint!

    var ingredient: Ingredient?

    private var articles: [Article] = []
    private var articlesListener: ListenerRegistration?

    private let db = Firestore.firestore()

    static func storyboardInstance(ingredient: Ingredient) -> IngredientViewController {
        let storyboard = UIStoryboard(name: "IngredientViewController", bundle: nil)
        let viewController = storyboard.instantiateInitialViewController() as! IngredientViewController
        viewController.ingredient = ingredient
        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let ingredient = ingredient else {
            navigationController?.popViewController(animated: true)
            return
        }

        imageView.sd_setImage(with: URL(string: ingredient.imageURLString), completed: nil)
        nameLabel.text = ingredient.name

        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(UINib(nibName: "ArticleTableViewCell", bundle: nil), forCellReuseIdentifier: "ArticleTableViewCell")
        let tableFooterView = UIView(frame: CGRect.zero)
        tableView.tableFooterView = tableFooterView

        articlesListener = db.collection("Articles").whereField("ingredient_id", isEqualTo: ingredient.documentID).addSnapshotListener({ (snapshot, error) in
            if let error = error {
                print(error)
            }

            snapshot?.documentChanges.forEach({ (change) in
                self.handleDocumentChange(change)
            })
        })
    }

    private func handleDocumentChange(_ change: DocumentChange) {
        switch change.type {
        case .added:
            insertNewArticle(document: change.document)
        default:
            //TODO
            print("TODO")
        }
        tableView.reloadData()
    }

    private func insertNewArticle(document: DocumentSnapshot) {
        guard let article = Article(document: document) else {
            return
        }

        document.reference.collection("sub_categories").getDocuments { (snapshot, error) in
            if let error = error {
                print(error)
            }

            snapshot?.documents.forEach({ (document) in
                guard let subArticle = SubArticle(document: document) else {
                    return
                }
                article.subArticles.append(subArticle)
                self.tableView.reloadData()
            })
        }
        
        articles.append(article)
    }
}

extension IngredientViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let article = articles[indexPath.section]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleTableViewCell") as! ArticleTableViewCell

        cell.titleLabel.text = article.title
        cell.delegate = self

        //TODO: Devide method
        var content = ""
        article.subArticles.forEach { (subArticle) in
            content += String(format: "%@\n", subArticle.title)
            content += "\n"
            subArticle.contents.forEach({ (str) in
                content += String(format: " %@\n", str)
                content += "\n"
            })
        }

        cell.contentLabel.text = content

        return cell
    }
}

extension IngredientViewController: ArticleTableViewCellDelegate {
    func readMoreButtonDidTapped() {
        //TODO: Fix tableView height
        tableViewConstraint.constant = 4000
        tableView.needsUpdateConstraints()
        tableView.reloadData()
    }
}
