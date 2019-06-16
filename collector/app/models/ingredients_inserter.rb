require 'csv'
require "google/cloud/firestore"

class IngredientsInserter
  PROJECT_ID = "seasonal-food"
  def run
    file_name = ENV['FILE_NAME']
    raise("please enter source csv file name") if file_name.nil?

    firestore = Google::Cloud::Firestore.new(project_id: PROJECT_ID)

    csv = CSV.read(file_name, headers: true)
    csv.each do |data|
      category = data["category"]
      name = data["name"]
      image_url = data["image_url"]
      shun_array = JSON.parse(data["shun_array"])
      articles_jsons = JSON.parse(data["articles_json"])
      ingredient_ref = firestore.col("Ingredients").add({ name: name, category: category, image_url: image_url, seasons: shun_array })
      articles_ids = []
      articles_jsons.each do |json|
        article_ref = firestore.col("Articles").add({ title: json["title"], ingredient_id: ingredient_ref.document_id })
        articles_ids << article_ref.document_id
        json["sub_categories"].each do |category_json|
          article_ref.col("sub_categories").add(title: category_json["title"], contents: category_json["contents"])
        end
      end
      ingredient_ref.update({articles_ids: articles_ids})
    end
  end
end
