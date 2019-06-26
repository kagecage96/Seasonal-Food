import UIKit

class IngredientsCollectionReusableView: UICollectionReusableView {

    @IBOutlet weak var label: UILabel!

    static let identifier: String = "IngredientsCollectionReusableView"

    static func nib() -> UINib {
        return UINib(nibName: IngredientsCollectionReusableView.identifier, bundle: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        label.font = .shun_normal(size: 14)
        label.textColor = .shun_black
    }    
}
