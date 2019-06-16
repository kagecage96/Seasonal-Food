import UIKit
import Firebase
import SDWebImage

class IngredientsViewController: UIViewController {
    internal enum IngredientSection: Int {
        case seafood = 0
        case vegitable = 1
        case fruit = 2
        case others = 3
    }

    @IBOutlet weak var monthTextField: UITextField!
    @IBOutlet weak var ingredientsCollectionView: UICollectionView!

    private var ingredients: [Ingredient] = []
    private var ingredientsListener: ListenerRegistration?
    private let headerTitles = ["Seafood", "Vegitable", "Fruit", "Others"]
    private let db = Firestore.firestore()

    var selectedMonth: Int = 1

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Seasonal Food"

        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.tintColor = .red
        toolBar.sizeToFit()

        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelPicker))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        monthTextField.inputAccessoryView = toolBar

        let pickerView = UIPickerView()
        pickerView.delegate = self
        monthTextField.inputView = pickerView

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

    @objc private func donePicker() {
        monthTextField.resignFirstResponder()
    }

    @objc private func cancelPicker() {
        monthTextField.placeholder = "選択してください"
        monthTextField.resignFirstResponder()
    }

    private func handleDocumentChange(_ change: DocumentChange) {
        switch change.type {
        case .added:
            insertNewIngredient(document: change.document)
        default:
            //TODO
            print("TODO")
        }
    }

    private func insertNewIngredient(document: DocumentSnapshot) {
        guard let ingredient = Ingredient(document: document) else {
            return
        }
        ingredients.append(ingredient)
        ingredientsCollectionView.reloadData()
    }

    private func ingredients(from category: Ingredient.Category, month: Int) -> [Ingredient] {
        return ingredients.filter({ (ingredient) -> Bool in
            return ingredient.category == category && ingredient.isSeason(month: month)
        })
    }

    private func ingredients(from section: Int, month: Int) -> [Ingredient] {
        guard let ingredientSection = IngredientSection(rawValue: section) else {
            return []
        }

        switch ingredientSection {
        case .seafood:
            return ingredients(from: .seafood, month: selectedMonth)
        case .vegitable:
            return ingredients(from: .vegitable, month: selectedMonth)
        case .fruit:
            return ingredients(from: .fruit, month: selectedMonth)
        case .others:
            return ingredients(from: .other, month: selectedMonth)
        }
    }
}

extension IngredientsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = ingredients(from: section, month: selectedMonth).count
        return arrangeInSectionCount(count: count)
    }

    private func arrangeInSectionCount(count: Int) -> Int {
        let maxInSectionCount = 6
        if count > maxInSectionCount {
            return maxInSectionCount
        } else {
            return count
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IngredientCollectionViewCell", for: indexPath) as! IngredientCollectionViewCell

        let ingredient = ingredients(from: indexPath.section, month: selectedMonth)[indexPath.row]

        let imageURL = URL(string: ingredient.imageURLString)
        cell.imageView.sd_setImage(with: imageURL, completed: nil)
        cell.label.text = ingredient.name
        return cell
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

extension IngredientsViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return (1...12).count
    }

    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(row + 1)
    }

    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedMonth = row + 1
        monthTextField.text = String(row + 1)
        ingredientsCollectionView.reloadData()
    }
}
