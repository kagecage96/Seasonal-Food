import UIKit
import Firebase
import SDWebImage

class HomeViewController: UIViewController {
    struct IngredientSection {
        let categoryID: String
        let categoryJPName: String

        init(categoryID: String, categoryJPName: String) {
            self.categoryID = categoryID
            self.categoryJPName = categoryJPName
        }
    }

    @IBOutlet weak var monthTextField: UITextField!
    @IBOutlet weak var ingredientsCollectionView: UICollectionView!

    private var ingredientSections: [IngredientSection] = []
    private var ingredients: [Ingredient] = []
    private var ingredientsListener: ListenerRegistration?
    private let headerTitles = ["Seafood", "Vegetable", "Fruit", "Others"]
    private let db = Firestore.firestore()

    var selectedMonthNumber: Int = 1

    override func viewDidLoad() {
        super.viewDidLoad()

        let backButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButtonItem
        navigationItem.title = "Seasonal Food"

        let date = Date()
        let calendar = Calendar.current
        selectedMonthNumber = calendar.component(.month, from: date)
        prepareTextField()

        ingredientsCollectionView.delegate = self
        ingredientsCollectionView.dataSource = self
        ingredientsCollectionView.register(UINib(nibName: "IngredientCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "IngredientCollectionViewCell")
        ingredientsCollectionView.register(CollectionViewSectionHeader.nib(), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CollectionViewSectionHeader.identifier)
        guard let collectionViewLayout = ingredientsCollectionView?.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        collectionViewLayout.headerReferenceSize = CGSize(width: self.view.bounds.width, height: 33)

        ingredientsListener = db.collection("Ingredients").addSnapshotListener({ (snapshot, error) in
            if let error = error {
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

    private func prepareTextField() {
        monthTextField.backgroundColor = .shun_extra_light_gray
        monthTextField.layer.borderColor = UIColor.shun_extra_light_gray.cgColor
        monthTextField.layer.cornerRadius = 20
        monthTextField.font = .shun_normal(size: 16)
        monthTextField.textColor = .shun_black
        monthTextField.text = DateFormatter().monthSymbols[selectedMonthNumber-1]

        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.tintColor = .shun_green
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
    }

    private func handleDocumentChange(_ change: DocumentChange) {
        switch change.type {
        case .added:
            insertNewIngredient(document: change.document)
        default: break
        }
    }

    private func insertNewIngredient(document: DocumentSnapshot) {
        guard let ingredient = Ingredient(document: document) else {
            return
        }
        ingredients.append(ingredient)
        insertNewCategoryIfNeeded(ingredient)

        ingredientsCollectionView.reloadData()
    }

    private func insertNewCategoryIfNeeded(_ ingredient: Ingredient) {
        let shouldAddNewSection = !ingredientSections.contains { (section) -> Bool in
            section.categoryID == ingredient.subCategory
        }

        if shouldAddNewSection {
            let section = IngredientSection(categoryID: ingredient.subCategory, categoryJPName: ingredient.subCategoryNameJP)
            ingredientSections.append(section)
        }
    }

    private func ingredients(section: Int, month: Int) -> [Ingredient] {
        let ingredientSection = ingredientSections[section]

        return ingredients.filter({ (ingredient) -> Bool in
            return ingredient.subCategory == ingredientSection.categoryID && ingredient.isSeason(month: month)
        })
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = ingredients(section: section, month: selectedMonthNumber).count
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
        return ingredientSections.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IngredientCollectionViewCell", for: indexPath) as! IngredientCollectionViewCell

        let ingredient = ingredients(section: indexPath.section, month: selectedMonthNumber)[indexPath.row]

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
            header.label.text = ingredientSections[indexPath.section].categoryJPName
            header.section = indexPath.section
            header.delegate = self
            return header
        }

        return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat =  19
        let margin: CGFloat = 18
        let collectionViewSize = collectionView.frame.size.width - 2*padding - 2*margin

        return CGSize(width: collectionViewSize/3, height: collectionViewSize*1.50/3)
    }
}

extension HomeViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return (1...12).count
    }

    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return DateFormatter().monthSymbols[row]
    }

    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedMonthNumber = row + 1
        monthTextField.text = DateFormatter().monthSymbols[row]
        ingredientsCollectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let ingredient = ingredients(section: indexPath.section, month: selectedMonthNumber)[indexPath.row]

        let viewController = IngredientViewController.storyboardInstance(ingredient: ingredient)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension HomeViewController: CollectionViewSectionHeaderDelegate {
    func seeAllButtonTapped(section: Int) {
        let ingredientSection = ingredientSections[section]
        let month = DateFormatter().monthSymbols[selectedMonthNumber-1]
        let categorizedIngredient = ingredients(section: section, month: selectedMonthNumber)

        let viewController = IngredientsViewController.storyboardInstance(ingredients: categorizedIngredient, ingredientTypeString: ingredientSection.categoryJPName, month: month)
        navigationController?.pushViewController(viewController, animated: true)
    }
}
