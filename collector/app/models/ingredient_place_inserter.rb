require 'csv'
require "google/cloud/firestore"

class IngredientPlaceInserter
  PROJECT_ID = "seasonal-food"

  def self.run
    firestore = Google::Cloud::Firestore.new(project_id: PROJECT_ID)
    firestore.collection("Ingredients").get.each do |col|
      col.ref.update({ local_location_name: "tokyo"})
    end
  end
end
