class SeafoodScraper < ScraperBase
  SEAFOOD_URLS = [
    'https://foodslink.jp/syokuzaihyakka/syun/monthly/janvier-fi.htm',
    'https://foodslink.jp/syokuzaihyakka/syun/monthly/fevrier-fi.htm',
    'https://foodslink.jp/syokuzaihyakka/syun/monthly/mars-fi.htm',
    'https://foodslink.jp/syokuzaihyakka/syun/monthly/avril-fi.htm',
    'https://foodslink.jp/syokuzaihyakka/syun/monthly/mai-fi.htm',
    'https://foodslink.jp/syokuzaihyakka/syun/monthly/juin-fi.htm',
    'https://foodslink.jp/syokuzaihyakka/syun/monthly/juillet-fi.htm',
    'https://foodslink.jp/syokuzaihyakka/syun/monthly/aout-fi.htm',
    'https://foodslink.jp/syokuzaihyakka/syun/monthly/septembre-fi.htm',
    'https://foodslink.jp/syokuzaihyakka/syun/monthly/octobre-fi.htm',
    'https://foodslink.jp/syokuzaihyakka/syun/monthly/novembre-fi.htm',
    'https://foodslink.jp/syokuzaihyakka/syun/monthly/decembre-fi.htm'
  ]

  def run
    start_index = ENV['START_INDEX'].present? ? ENV['START_INDEX'].to_i : 0

    begin
      seafoods = fetch_seafoods
      seafoods.uniq! { |item| item.name }
      puts("#{seafoods.count}件のデータ取得を開始します。")
    rescue => e
      puts(e)
      puts("fetch urls try again")
      seafoods = fetch_seafoods
    end
    fetch_seafood_detail_data!(seafoods, 0)
    CSV.open('seafoods.csv', 'w') do |csv|
      csv << HEADER
      seafoods.each do |seafood|
        csv << ['seafood', seafood.name, seafood.image_url, seafood.page_url, seafood.articles.to_json, seafood.shun_array]
      end
    end
  end

  def fetch_seafood_detail_data!(seafoods, start_index)
    seafoods[start_index..-1].each.with_index(start_index+1) do |seafood, i|
      begin
        puts("#{i}番目")
        fetch_and_set_seafoods_detail!(seafood)
      rescue => e
        puts(e)
        puts("fetch detail try agrain")
        sleep(2)
        fetch_seafood_detail_data!(seafoods, i)
      end
    end
  end

  def fetch_and_set_seafoods_detail!(seafood)
    puts("scrapint #{seafood.name}")
    puts("scrapint #{seafood.page_url}")

    doc = fetch_nokogiri_doc(seafood.page_url)
    current_h2 = nil
    current_h3 = nil

    calendar_element = doc.search('#calendar-fish').first
    if calendar_element.present?
      calendar_element.search('td').each_with_index do |element, i|
        if element.attributes.present? && element.attributes["bgcolor"].present?
          seafood.shun_array[i] = true
        else
          seafood.shun_array[i] = false
        end
      end
    end

    doc.search('article')[0].children.each do |element|
      # h2, h3 が階層構造になっていないので、探索して処理する
      # 次の h2 が現れるまで current_h2 として保持しておき、それで h3 にタグ付けする
      if valid_h2?(element)
        current_h2 = element.text
        seafood.articles << Ingredient::Article.new(current_h2)
      elsif valid_h3(element)
        current_h3 = element.text
        target_article = seafood.articles.find { |article| article.title == current_h2 }
        target_article.sub_categories << Ingredient::SubCategory.new(element.text) if target_article.present?
      elsif valid_h4(element)
        target_article = seafood.articles.find { |article| article.title == current_h2 }
        break if target_article.blank?
        target_sub_category = target_article.sub_categories.find { |sub_category| sub_category.title == current_h3 }
        target_sub_category.contents << element.text if target_sub_category.present?
      end
    end
  end

  def fetch_seafoods
    seafoods = []
    SEAFOOD_URLS.each do |url|
      doc = fetch_nokogiri_doc(URI.encode(url))
      doc.search('.monthlyimagebox-fish').each do |element|
        seafood = Ingredient.new
        begin
          seafood.name = element.search('a').text
          seafood.image_url = IMAGE_URL_BASE + element.search('img').first.attributes["src"].value.remove('..')
          seafood.page_url = DETAIL_URL_BASE + element.search('a').first.attributes['href'].value.remove('..')
          seafoods << seafood
        rescue => e
          print(e)
        end
      end
    end
    seafoods
  end

  def valid_h2?(element)
    return false if element.attributes['class'].blank?
    return false if element.name != 'h2'
    return false if element.attributes['class'].value != "sab-title-s"
    return false if element.text.include?('写真')
    return false if element.text.include?('画像')
    return true
  end

  def valid_h3(element)
    return false if element.attributes['class'].blank?
    return false if !element.attributes['class'].value.include?("midashi")
    return false if element.name != 'h3'
    return true
  end

  def valid_h4(element)
    return false if element.attributes['class'].blank?
    return false if !element.attributes['class'].value.include?("doc-s")
    return true
  end
end
