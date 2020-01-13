require 'csv'
require "google/cloud/firestore"

class ReplaceIngredientSubCategoryJob
  PROJECT_ID = "seasonal-food"

  def self.run
    firestore = Google::Cloud::Firestore.new(project_id: PROJECT_ID)
    firestore.collection("Ingredients").get.each do |col|
      unless col.data[:sub_category_id].present?
        sub_category_id = nil
        case col.data[:sub_category]
        when "root_vegetables"
          sub_category_id = 'IRweO1EJl85TLmYzGqWV'
        when "fruit"
          sub_category_id = 'Ve0ZJCPbpDJZZjSEZFUF'
        when 'fish'
          sub_category_id = 'qtXLVN0YgaT7aoyS9iyr'
        when 'leafy_vegetables'
          sub_category_id = 'Bbn41dnfbNCBIMBMT6Dm'
        when 'vegetable_fruit'
          sub_category_id = 'jItwp3lMrhpHBhhil99v'
        when 'octopus_squid'
          sub_category_id = '7ZVcMd2KisklojfaIQEc'
        when 'shellfish'
          sub_category_id = 'e33e0oyQojWKieh3T3qR'
        when 'mushroom'
          sub_category_id = 'EzBNSB2WcZDIZ25rbnnw'
        when 'crustacean'
          sub_category_id = 'e33e0oyQojWKieh3T3qR'
        end

        col.ref.update( { sub_category_id: sub_category_id } )
      end
    end
  end
end
