import UIKit

protocol CollectionViewSectionHeaderDelegate {
    func seeAllButtonTapped(section: Int)
}

class CollectionViewSectionHeader: UICollectionReusableView {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var seeAllButton: UIButton!

    var delegate: CollectionViewSectionHeaderDelegate?
    var section: Int?

    static let identifier: String = "CollectionViewSectionHeader"

    static func nib() -> UINib {
        return UINib(nibName: CollectionViewSectionHeader.identifier, bundle: nil)
    }

    override func awakeFromNib() {
        label.textColor = .shun_black
        label.font = .shun_bold(size: 26)

        seeAllButton.tintColor = .shun_green
        seeAllButton.titleLabel?.font = .shun_normal(size: 16)
    }

    @IBAction func seeAllButtonDidTapped(_ sender: Any) {
        guard let section = section else { return }
        delegate?.seeAllButtonTapped(section: section)
    }
}
