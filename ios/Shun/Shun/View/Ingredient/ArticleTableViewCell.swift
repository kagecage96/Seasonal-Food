import UIKit

protocol ArticleTableViewCellDelegate {
    func readMoreButtonDidTapped()
}

class ArticleTableViewCell: UITableViewCell {

    var isExpanded: Bool = false
    var delegate: ArticleTableViewCellDelegate?

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var readMoreButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func readMoreButtonDidTapped(_ sender: Any) {
        isExpanded = true
        readMoreButton.isHidden = true
        contentLabel.numberOfLines = 0
        delegate?.readMoreButtonDidTapped()
    }
}
