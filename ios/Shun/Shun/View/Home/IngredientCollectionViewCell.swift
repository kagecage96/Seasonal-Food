import UIKit

class IngredientCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!

    static let identifier: String = "IngredientCollectionViewCell"

    static func nib() -> UINib {
        return UINib(nibName: IngredientCollectionViewCell.identifier, bundle: nil)
    }

    override func awakeFromNib() {
        imageView.layer.borderColor = UIColor.shun_light_gray.cgColor
        imageView.layer.borderWidth = 1.0
        imageView.layer.cornerRadius = 10.0

        label.font = .shun_bold(size: 14)
        label.textColor = .shun_black
    }
}
