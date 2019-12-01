require 'csv'
require "google/cloud/firestore"

class IngredientLanguageInserter
  PROJECT_ID = "seasonal-food"

  def self.run
    firestore = Google::Cloud::Firestore.new(project_id: PROJECT_ID)
    firestore.collection("Ingredients").get.each do |col|
      col.ref.update({ japanese_name: col.data[:name] })
    end
  end
end
