import UIKit

class ArticleViewController: UIViewController {
    var article: Article?
    @IBOutlet weak var label: UILabel!

    static func storyboardInstance(article: Article) -> ArticleViewController {
        let storyboard = UIStoryboard(name: "ArticleViewController", bundle: nil)
        let viewController = storyboard.instantiateInitialViewController() as! ArticleViewController
        viewController.article = article
        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let article = article else {
            navigationController?.popViewController(animated: true)
            return
        }
        let backButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButtonItem
        navigationItem.title = article.title

        label.font = .shun_normal(size: 14)
        label.textColor = .shun_black

        label.text = article.subArticleText()
    }
}
