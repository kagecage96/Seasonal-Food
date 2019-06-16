import UIKit
import Firebase
import SDWebImage

class IngredientsViewController: UIViewController {
    @IBOutlet weak var seasonSelectionButton: NSLayoutConstraint!
    @IBOutlet weak var ingredientsCollectionView: UICollectionView!

    private var ingredients: [Ingredient] = []
    private var ingredientsListener: ListenerRegistration?

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
        ingredients.append(ingredient)
    }
}

extension IngredientsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if ingredients.count > 6 {
            return 6
        } else {
            return ingredients.count
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IngredientCollectionViewCell", for: indexPath) as! IngredientCollectionViewCell
        let ingredient = ingredients[indexPath.row]
        let imageURL = URL(string: ingredient.imageURLString)
        cell.imageView.sd_setImage(with: imageURL, completed: nil)
        cell.label.text = ingredients[indexPath.row].name
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "CollectionViewSectionHeader", for: indexPath) as? CollectionViewSectionHeader else {
            fatalError("Could not find proper header")
        }

        if kind == UICollectionView.elementKindSectionHeader {
            //TODO: Add label title
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

