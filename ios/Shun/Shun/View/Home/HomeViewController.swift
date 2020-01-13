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
    @IBOutlet weak var placeTextField: UITextField!
    
    @IBOutlet weak var ingredientsCollectionView: UICollectionView!

    private var ingredientSections: [IngredientSection] = []
    private var ingredients: [Ingredient] = []
    private var ingredientsListener: ListenerRegistration?
    
    private var subCategoryIDs: [String] = []
        
    private let headerTitles = ["Seafood", "Vegetable", "Fruit", "Others"]
    private let db = Firestore.firestore()

    var selectedMonthNumber: Int = 1
    var selectedPrefecture: Prefecture = .tokyo

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
        monthTextField.resignFirstResponder()
    }
    
    @objc private func placePickerDoneButtonTapped() {
        placeTextField.resignFirstResponder()
    }
    
    @objc private func placePickerCancelButtonTapped() {
        placeTextField.resignFirstResponder()
    }

    private func prepareTextField() {
        monthTextField.tag = 0
        monthTextField.backgroundColor = .shun_extra_light_gray
        monthTextField.layer.borderColor = UIColor.shun_extra_light_gray.cgColor
        monthTextField.layer.cornerRadius = 20
        monthTextField.font = .shun_normal(size: 16)
        monthTextField.textColor = .shun_black
        monthTextField.text = DateFormatter().monthSymbols[selectedMonthNumber-1]
        monthTextField.tintColor = .clear

        let monthToolBar = UIToolbar()
        monthToolBar.barStyle = .default
        monthToolBar.tintColor = .shun_green
        monthToolBar.sizeToFit()

        let monthDoneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePicker))
        let monthSpaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let monthCancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelPicker))
        monthToolBar.setItems([monthCancelButton, monthSpaceButton, monthDoneButton], animated: false)
        monthToolBar.isUserInteractionEnabled = true
        monthTextField.inputAccessoryView = monthToolBar

        let monthPickerView = UIPickerView()
        monthPickerView.delegate = self
        monthPickerView.tag = monthTextField.tag
        monthTextField.inputView = monthPickerView
        
        placeTextField.tag = 1
        placeTextField.backgroundColor = .shun_extra_light_gray
        placeTextField.layer.borderColor = UIColor.shun_extra_light_gray.cgColor
        placeTextField.layer.cornerRadius = 20
        placeTextField.font = .shun_normal(size: 16)
        placeTextField.textColor = .shun_black
        
        placeTextField.text = Prefecture.tokyo.name(language: Configuration.shared.language).capitalized
        placeTextField.tintColor = .clear
        
        let placeToolBar = UIToolbar()
        placeToolBar.barStyle = .default
        placeToolBar.tintColor = .shun_green
        placeToolBar.sizeToFit()
        
        let placeDoneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(placePickerDoneButtonTapped))
        let placeSpaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let placeCancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(placePickerCancelButtonTapped))
        
        placeToolBar.setItems([placeCancelButton, placeSpaceButton, placeDoneButton], animated: false)
        placeToolBar.isUserInteractionEnabled = true
        
        placeTextField.inputAccessoryView = placeToolBar
        
        let placePickerView = UIPickerView()
        placePickerView.delegate = self
        placePickerView.tag = placeTextField.tag
        placeTextField.inputView = placePickerView
        
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
        
        let shouldAddNewSection = !self.subCategoryIDs.contains { (categoryID) -> Bool in
            return categoryID == ingredient.subCategoryID
        }
                
        if shouldAddNewSection {
            self.subCategoryIDs.append(ingredient.subCategoryID)
            db.collection("SubCategories").document(ingredient.subCategoryID).getDocument { (document, error) in
                if let document = document, document.exists {
                    guard let category = SubCategory(document: document) else { return }
                    let section = IngredientSection(categoryID: ingredient.subCategoryID, categoryJPName: category.name)
                    self.ingredientSections.append(section)
                    self.ingredientsCollectionView.reloadData()
                } else {
                    print("Document does not exist")
                }
            }
        }
    }

    private func ingredients(section: Int, month: Int) -> [Ingredient] {
        let ingredientSection = ingredientSections[section]

        return ingredients.filter({ (ingredient) -> Bool in
            return ingredient.subCategoryID == ingredientSection.categoryID && ingredient.isSeason(month: month) && ingredient.locations.contains(selectedPrefecture.engName)
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
        if pickerView.tag == monthTextField.tag {
            return DateFormatter().monthSymbols.count
        } else if pickerView.tag == placeTextField.tag {
            return Prefecture.allCases.count
        }
        return 0
    }

    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == monthTextField.tag {
            return DateFormatter().monthSymbols[row]
        } else if pickerView.tag == placeTextField.tag {
            return prefectureNames()[row]
        }
        return nil
    }

    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == monthTextField.tag {
            selectedMonthNumber = row + 1
            monthTextField.text = DateFormatter().monthSymbols[row]
            ingredientsCollectionView.reloadData()
        }  else if pickerView.tag == placeTextField.tag {
            let prefectures = Prefecture.allCases
            placeTextField.text = prefectureNames()[row]
            selectedPrefecture = prefectures[row]
            ingredientsCollectionView.reloadData()
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let ingredient = ingredients(section: indexPath.section, month: selectedMonthNumber)[indexPath.row]

        let viewController = IngredientViewController.storyboardInstance(ingredient: ingredient)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func prefectureNames() -> [String] {
        let prefectures = Prefecture.allCases
        return prefectures.map { $0.name(language: Configuration.shared.language).capitalized }
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
