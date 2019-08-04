require 'csv'

class CollectMekikiInfoScraper < ScraperBase
  def run
    file_name = ENV['FILE_NAME']
    raise("please enter source csv file name") if file_name.nil?

    ingredient_array = []

    csv = CSV.read(file_name, headers: true)
    csv.each do |data|
      begin
        category = data["category"]
        sub_category_jp = data["subcategory_jp"]
        sub_category_en = data["sub_category_en"]
        name = data["name"]
        image_url = data["image_url"]
        page_url = data["page_url"]
        mekiki_url = data["mekiki_url"]
        shun_array = JSON.parse(data["shun_array"])
        articles_jsons = JSON.parse(data["articles_json"]) if data["articles_json"].present?
        doc = fetch_nokogiri_doc(mekiki_url)

        elements = artile_elements(doc)
        articles = []
        current_h2 = nil
        current_h3 = nil

        elements.each do |element|
          if valid_h2?(element)
            current_h2 = element.text
            next if !current_h2.include?("選") && !current_h2.include?("目利き") && !current_h2.include?("見分け方")
            articles << Ingredient::Article.new(current_h2)
          elsif valid_h3(element)
            current_h3 = element.text
            target_article = articles.find { |a| a.title == current_h2 }
            target_article.sub_categories << Ingredient::SubCategory.new(element.text) if target_article.present?
          elsif valid_h4(element)
            target_article = articles.find { |a| a.title == current_h2 }
            next if target_article.blank?
            target_sub_category = target_article.sub_categories.find { |sub_category| sub_category.title == current_h3 }
            target_sub_category.contents << element.text if target_sub_category.present?
          end
        end

        if articles.blank?
          puts mekiki_url
        else
          article = articles[0]
          articles_jsons << JSON.parse(article.to_json)
        end
        ingredient_array << [category, sub_category_en, sub_category_jp, name, image_url, page_url, articles_jsons.to_json, shun_array, mekiki_url]
      rescue => e
        puts e
        sleep(3) if e.to_s == "503 Service Temporarily Unavailable"
        ingredient_array << [category, sub_category_en, sub_category_jp, name, image_url, page_url, articles_jsons.to_json, shun_array, mekiki_url]
      end
    end
    puts ingredient_array.count
    ingredient_array.uniq! { |item| item[5] }
    puts ingredient_array.count
    CSV.open('mekikied.csv','w') do |csv|
      ingredient_array.each do |a|
        csv << a
      end
    end
  end

  def artile_elements(doc)
    return doc.search('article')[0].children if doc.search('article')[0].present?
    return doc.search('td')[20].children[1].search('td')[0].children if doc.search('td')[20].children[1].search('td')[0].children.present?
    return doc.search('td')[20].children
  end

  def valid_h2?(element)
    return false if element.attributes['class'].blank?
    return false if element.name != 'h2' && element.name != 'p'
    return false if !element.attributes['class'].value.include?("sab-title") && !element.attributes['class'].value.include?("h2")
    return false if element.text.include?('写真')
    return false if element.text.include?('画像')
    return true
  end

  def valid_h3(element)
    return false if element.attributes['class'].blank?
    return false if !element.attributes['class'].value.include?("midashi") && !element.attributes['class'].value.include?("h3")
    return false if element.name != 'h3'
    return true
  end

  def valid_h4(element)
    return false if element.attributes['class'].blank?
    return false if !element.attributes['class'].value.include?("doc")
    return true
  end
end
