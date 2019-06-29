import UIKit

class ArticleImageTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ingredientImageView: UIImageView!

    static let identifier: String = "ArticleImageTableViewCell"

    static func nib() -> UINib {
        return UINib(nibName: ArticleImageTableViewCell.identifier, bundle: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        nameLabel.font = .shun_bold(size: 26)
        nameLabel.textColor = .shun_black
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
