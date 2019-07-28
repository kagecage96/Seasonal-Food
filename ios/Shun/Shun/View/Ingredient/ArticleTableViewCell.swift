import UIKit

protocol ArticleTableViewCellDelegate {
    func readMoreButtonDidTapped(indexPath: IndexPath)
}

class ArticleTableViewCell: UITableViewCell {

    var delegate: ArticleTableViewCellDelegate?
    var indexPath: IndexPath?

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
        guard let indexPath = indexPath else { return }
        delegate?.readMoreButtonDidTapped(indexPath: indexPath)
    }
}
