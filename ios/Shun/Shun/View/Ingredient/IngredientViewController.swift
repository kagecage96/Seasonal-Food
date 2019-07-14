import UIKit
import Firebase
import SDWebImage

class IngredientViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var recipeButton: UIButton!
    @IBOutlet weak var restaurantButton: UIButton!

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

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.setBackgroundImage(nil  , for: .default)
        navigationController?.navigationBar.shadowImage = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let ingredient = ingredient else {
            navigationController?.popViewController(animated: true)
            return
        }

        [recipeButton, restaurantButton].forEach { (button: UIButton) in
            button.backgroundColor = .shun_green
            button.layer.cornerRadius = 20.0
            button.setTitleColor(.white, for: .normal)
            button.setImage(#imageLiteral(resourceName: "search_icon"), for: .normal)
            button.tintColor = .white
            button.imageEdgeInsets = UIEdgeInsets(top: 0.0, left: -10.0, bottom: 0.0, right: 0.0)
        }

        recipeButton.setTitle("Recipes", for: .normal)
        restaurantButton.setTitle("Restaurants", for: .normal)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.register(UINib(nibName: "ArticleTableViewCell", bundle: nil), forCellReuseIdentifier: "ArticleTableViewCell")
        tableView.register(ArticleImageTableViewCell.nib(), forCellReuseIdentifier: ArticleImageTableViewCell.identifier)
        

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

    @IBAction func recipeButtonDidTapped(_ sender: Any) {
        guard let name = ingredient?.name else {
            return
        }
        let urlString = "https://www.google.co.jp/search?q=\(name) レシピ"
        let encodeUrlString: String = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: encodeUrlString)!

        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }

    @IBAction func restaurantButtonDidTapped(_ sender: Any) {
        guard let name = ingredient?.name else {
            return
        }
        let urlString = "https://www.google.co.jp/search?q=\(name) レストラン"
        let encodeUrlString: String = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: encodeUrlString)!

        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

extension IngredientViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            return articles.count
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: ArticleImageTableViewCell.identifier) as! ArticleImageTableViewCell
            guard let ingredient = ingredient else { return cell }
            let url = URL(string: ingredient.imageURLString)
            cell.ingredientImageView?.sd_setImage(with: url, completed: nil)
            cell.nameLabel.text = ingredient.name
            return cell
        default:
            let article = articles[indexPath.section-1]
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
}

extension IngredientViewController: ArticleTableViewCellDelegate {
    func readMoreButtonDidTapped(newCellHeight: CGFloat) {
        tableView.beginUpdates()
        tableView.updateConstraints()
        tableView.reloadData()
        tableView.endUpdates()
    }
}
