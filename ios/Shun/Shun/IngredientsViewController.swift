import UIKit
import Firebase
import SDWebImage

class IngredientsViewController: UIViewController {
    enum IngredientSection: Int {
        case seafood = 0
        case vegitable = 1
        case fruit = 2
        case others = 3
    }

    @IBOutlet weak var seasonSelectionButton: NSLayoutConstraint!
    @IBOutlet weak var ingredientsCollectionView: UICollectionView!

    private var vegitables: [Ingredient] = []
    private var seafoods: [Ingredient] = []
    private var fruits: [Ingredient] = []
    private var otherIngredients: [Ingredient] = []

    private var ingredientsListener: ListenerRegistration?

    private let headerTitles = ["Seafood", "Vegitable", "Fruit", "Others"]

    private let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Seasonal Food"
        ingredientsCollectionView.delegate = self
        ingredientsCollectionView.dataSource = self
        ingredientsCollectionView.register(UINib(nibName: "IngredientCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "IngredientCollectionViewCell")
        ingredientsListener = db.collection("Ingredients").addSnapshotListener({ (snapshot, error) in
            if let error = error {
                //TODO: Error handling
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
            insertNewIngredient(document: change.document)
        default:
            print("hoge")
        }
    }

    private func insertNewIngredient(document: DocumentSnapshot) {
        guard let ingredient = Ingredient(document: document) else {
            return
        }
        switch ingredient.category {
        case .seafood:
            seafoods.append(ingredient)
        case .vegitable:
            vegitables.append(ingredient)
        case .fruit:
            fruits.append(ingredient)
        case .other:
            otherIngredients.append(ingredient)
        }
        ingredientsCollectionView.reloadData()
    }
}

extension IngredientsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        guard let ingredientSection = IngredientSection(rawValue: section) else {
            return 0
        }

        var count = 0

        switch ingredientSection {
        case .seafood:
            count = seafoods.count
        case .vegitable:
            count = vegitables.count
        case .fruit:
            count = fruits.count
        case .others:
            count = otherIngredients.count
        }
        return arrangeInSectionCount(count: count)
    }

    private func arrangeInSectionCount(count: Int) -> Int {
        if count > 6 {
            return 6
        } else {
            return count
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IngredientCollectionViewCell", for: indexPath) as! IngredientCollectionViewCell
        guard let ingredient = ingredient(from: indexPath) else {
            return cell
        }

        let imageURL = URL(string: ingredient.imageURLString)
        cell.imageView.sd_setImage(with: imageURL, completed: nil)
        cell.label.text = ingredient.name
        return cell
    }

    private func ingredient(from indexPath: IndexPath) -> Ingredient? {
        guard let ingredientSection = IngredientSection(rawValue: indexPath.section) else {
            return nil
        }

        switch ingredientSection {
        case .seafood:
            return seafoods[indexPath.row]
        case .vegitable:
            return vegitables[indexPath.row]
        case .fruit:
            return fruits[indexPath.row]
        case .others:
            return otherIngredients[indexPath.row]
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "CollectionViewSectionHeader", for: indexPath) as? CollectionViewSectionHeader else {
            fatalError("Could not find proper header")
        }

        if kind == UICollectionView.elementKindSectionHeader {
            header.label.text = headerTitles[indexPath.section]
            return header
        }

        return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat =  13
        let margin: CGFloat = 40
        let collectionViewSize = collectionView.frame.size.width - padding - margin
        return CGSize(width: collectionViewSize/3, height: collectionViewSize/3)
    }
}

