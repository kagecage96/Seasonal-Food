require 'csv'
require "google/cloud/firestore"

class DeleteIngredientSubCategoryFieldJob
  PROJECT_ID = "seasonal-food"

  def self.run
    firestore = Google::Cloud::Firestore.new(project_id: PROJECT_ID)
    firestore.collection("Ingredients").get.each do |col|
      col.ref.update({ sub_category: firestore.field_delete })
    end
  end
end
