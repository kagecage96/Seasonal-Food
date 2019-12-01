require 'csv'
require "google/cloud/firestore"

class ArticleLanguageInserter
  PROJECT_ID = "seasonal-food"

  def self.run
    firestore = Google::Cloud::Firestore.new(project_id: PROJECT_ID)
    firestore.collection("Articles").get.each do |col|
      col.ref.update({ language: "japanese"})
    end
  end
end
