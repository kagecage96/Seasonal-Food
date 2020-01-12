require 'csv'
require "google/cloud/firestore"

class IngredientLocationNamesInserter
  PROJECT_ID = "seasonal-food"

  def self.run
    firestore = Google::Cloud::Firestore.new(project_id: PROJECT_ID)
    firestore.collection("Ingredients").get.each do |col|
      col.ref.update({ location_names: firestore.field_delete })
      col.ref.update({ local_location_name: firestore.field_delete })
      col.ref.update({ category: firestore.field_delete })
      col.ref.update({ locations: [col[:local_location_name]]})
    end
  end
end
