import UIKit

class IngredientsViewController: UIViewController {
    var ingredients: [Ingredient] = []
    var ingredientTypeString: String?
    var month: String?

    @IBOutlet weak var collectionView: UICollectionView!

    static func storyboardInstance(ingredients: [Ingredient], ingredientTypeString: String, month: String) -> IngredientsViewController {
        let storyboard = UIStoryboard(name: "IngredientsViewController", bundle: nil)
        let viewController = storyboard.instantiateInitialViewController() as! IngredientsViewController
        viewController.ingredients = ingredients
        viewController.ingredientTypeString = ingredientTypeString
        viewController.month = month
        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = ingredientTypeString

        let backButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButtonItem

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "IngredientCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "IngredientCollectionViewCell")
        collectionView.register(IngredientsCollectionReusableView.nib(), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: IngredientsCollectionReusableView.identifier)
        guard let collectionViewLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        collectionViewLayout.headerReferenceSize = CGSize(width: self.view.bounds.width, height: 87)
    }
}

extension IngredientsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ingredients.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IngredientCollectionViewCell", for: indexPath) as! IngredientCollectionViewCell

        let ingredient = ingredients[indexPath.row]

        let imageURL = URL(string: ingredient.imageURLString)
        cell.imageView.sd_setImage(with: imageURL, completed: nil)
        cell.label.text = ingredient.name
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat =  19
        let margin: CGFloat = 18
        let collectionViewSize = collectionView.frame.size.width - 2*padding - 2*margin

        return CGSize(width: collectionViewSize/3, height: collectionViewSize*1.50/3)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "IngredientsCollectionReusableView", for: indexPath) as? IngredientsCollectionReusableView else {
            fatalError("Could not find proper header")
        }

        if kind == UICollectionView.elementKindSectionHeader {
            guard let month = month else { return UICollectionReusableView() }
            header.label.text = "\(month), Seasonal Food (\(ingredients.count))"
            return header
        }

        return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let ingredient = ingredients[indexPath.row]
        let viewController = IngredientViewController.storyboardInstance(ingredient: ingredient)
        navigationController?.pushViewController(viewController, animated: true)
    }
}
