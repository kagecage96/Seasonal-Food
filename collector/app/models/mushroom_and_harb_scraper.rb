class MushroomAndHarbScraper < ScraperBase
  TARGET_URLS = [
    'https://foodslink.jp/syokuzaihyakka/syun/vegitable/kinoko-index.htm'
  ]

  IMAGE_URL_BASE = "https://foodslink.jp/syokuzaihyakka"
  DETAIL_URL_BASE = "https://foodslink.jp/syokuzaihyakka/syun/vegitable/"

  def run
    start_index = ENV['START_INDEX'].present? ? ENV['START_INDEX'].to_i : 0

    begin
      ingredients = fetch_ingredients
      ingredients.uniq! { |item| item.image_url }
      puts("#{ingredients.count}件のデータ取得を開始します。")
    rescue => e
      puts(e)
      puts("fetch urls try again")
      ingredients = fetch_ingredients
    end

    fetch_ingredients_detail_data!(ingredients, 0)
    CSV.open('ingredients.csv', 'w') do |csv|
      csv << HEADER
      ingredients.each do |ingredient|
        csv << ['other', ingredient.name, ingredient.image_url, ingredient.page_url, ingredient.articles.to_json, ingredient.shun_array]
      end
    end
  end

  def fetch_ingredients
    ingredients = []
    TARGET_URLS.each do |url|
      doc = fetch_nokogiri_doc(URI.encode(url))
      doc.xpath('//body/table[2]/tr/td[2]/table/tr[2]/td/table').search('tr').search('img').each_with_index do |element, i|
        ingredient = Ingredient.new
        begin
          ingredient.image_url = IMAGE_URL_BASE + element.attributes["src"].text.remove('../..')
          ingredient.page_url = DETAIL_URL_BASE + element.parent.attributes["href"].value.remove('..')
          ingredient.name = doc.search('.index-kinoko')[i].text
          ingredients << ingredient
        rescue => e
          print(e)
        end
      end
    end
    ingredients
  end

  def fetch_ingredients_detail_data!(ingredients, start_index)
    ingredients[start_index..-1].each.with_index(start_index+1) do |ingredient, i|
      begin
        puts("#{i}番目")
        fetch_and_set_ingredients_detail!(ingredient)
      rescue => e
        puts(e)
        puts("fetch detail try agrain")
        sleep(2)
        fetch_and_set_ingredients_detail!(ingredient)
      end
    end
  end

  def fetch_and_set_ingredients_detail!(ingredient)
    puts("scrapint #{ingredient.name}")
    puts("scrapint #{ingredient.page_url}")

    doc = fetch_nokogiri_doc(ingredient.page_url)
    current_h2 = nil
    current_h3 = nil

    calendar_element = doc.search('#calendar').first
    if calendar_element.present?
      calendar_element.search('td').each_with_index do |element, i|
        if element.attributes.present? && element.attributes["bgcolor"].present?
          ingredient.shun_array[i] = true
        else
          ingredient.shun_array[i] = false
        end
      end
    end

    elements = artile_elements(doc)
    elements.each do |element|
      if valid_h2?(element)
        current_h2 = element.text
        ingredient.articles << Ingredient::Article.new(current_h2)
      elsif valid_h3(element)
        current_h3 = element.text
        target_article = ingredient.articles.find { |article| article.title == current_h2 }
        target_article.sub_categories << Ingredient::SubCategory.new(element.text) if target_article.present?
      elsif valid_h4(element)
        target_article = ingredient.articles.find { |article| article.title == current_h2 }
        break if target_article.blank?
        target_sub_category = target_article.sub_categories.find { |sub_category| sub_category.title == current_h3 }
        target_sub_category.contents << element.text if target_sub_category.present?
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
    return false if element.name != 'h2'
    return false if element.attributes['class'].value != "sab-title" && element.attributes['class'].value != "h2-kinoko"
    return false if element.text.include?('写真')
    return false if element.text.include?('画像')
    return true
  end

  def valid_h3(element)
    return false if element.attributes['class'].blank?
    return false if !element.attributes['class'].value.include?("midashi") && !element.attributes['class'].value.include?("h3-kinoko")
    return false if element.name != 'h3'
    return true
  end

  def valid_h4(element)
    return false if element.attributes['class'].blank?
    return false if !element.attributes['class'].value.include?("doc")
    return true
  end
end
