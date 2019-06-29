import UIKit

protocol ArticleTableViewCellDelegate {
    func readMoreButtonDidTapped(newCellHeight: CGFloat)
}

class ArticleTableViewCell: UITableViewCell {

    var isExpanded: Bool = false
    var delegate: ArticleTableViewCellDelegate?

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var readMoreButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()

        titleLabel.font = .shun_bold(size: 18)
        titleLabel.textColor = .shun_gray

        contentLabel.font = .shun_normal(size: 14)
        contentLabel.textColor = .shun_black

        readMoreButton.setTitleColor(.shun_green, for: .normal)
        readMoreButton.titleLabel?.font = .shun_normal(size: 14)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func readMoreButtonDidTapped(_ sender: Any) {
        isExpanded = true
        readMoreButton.isHidden = true
        contentLabel.numberOfLines = 0
        delegate?.readMoreButtonDidTapped(newCellHeight: frame.height)
    }
}
