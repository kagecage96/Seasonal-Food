class FruitScraper < ScraperBase
  FRUITS_URLS = [
    'https://foodslink.jp/syokuzaihyakka/syun/monthly/janvier-fr.htm',
    'https://foodslink.jp/syokuzaihyakka/syun/monthly/fevrier-fr.htm',
    'https://foodslink.jp/syokuzaihyakka/syun/monthly/mars-fr.htm',
    'https://foodslink.jp/syokuzaihyakka/syun/monthly/avril-fr.htm',
    'https://foodslink.jp/syokuzaihyakka/syun/monthly/mai-fr.htm',
    'https://foodslink.jp/syokuzaihyakka/syun/monthly/juin-fr.htm',
    'https://foodslink.jp/syokuzaihyakka/syun/monthly/juillet-fr.htm',
    'https://foodslink.jp/syokuzaihyakka/syun/monthly/aout-fr.htm',
    'https://foodslink.jp/syokuzaihyakka/syun/monthly/septembre-fr.htm',
    'https://foodslink.jp/syokuzaihyakka/syun/monthly/octobre-fr.htm',
    'https://foodslink.jp/syokuzaihyakka/syun/monthly/novembre-fr.htm',
    'https://foodslink.jp/syokuzaihyakka/syun/monthly/decembre-fr.htm'
  ]

  def run
    start_index = ENV['START_INDEX'].present? ? ENV['START_INDEX'].to_i : 0

    begin
      fruits = fetch_fruits
      fruits.uniq! { |item| item.name }
      puts("#{fruits.count}件のデータ取得を開始します。")
    rescue => e
      puts(e)
      puts("fetch urls try again")
      fruits = fetch_fruits
    end
    fetch_fruit_detail_data!(fruits, 0)
    CSV.open('fruits.csv', 'w') do |csv|
      csv << HEADER
      fruits.each do |fruit|
        csv << ['fruit', fruit.name, fruit.image_url, fruit.page_url, fruit.articles.to_json, fruit.shun_array]
      end
    end
  end

  def fetch_fruits
    fruits = []
    FRUITS_URLS.each_with_index do |url, i|
      doc = fetch_nokogiri_doc(URI.encode(url))
      doc.search('.monthlyimagebox-f').each do |element|
        begin
          name = element.search('a').text
          fruit = fruits.find { |fruit| fruit.name == name }
          if fruit.present?
            fruit.shun_array[i] = true
          else
            fruit = Ingredient.new
            fruit.name = name
            fruit.image_url = IMAGE_URL_BASE + element.search('img').first.attributes["src"].value.remove('..')
            fruit.page_url = DETAIL_URL_BASE + element.search('a').first.attributes['href'].value.remove('..')
            fruit.shun_array[i]
            fruits << fruit
          end
        rescue => e
          print(e)
        end
      end
    end
    fruits
  end

  def fetch_fruit_detail_data!(fruits, start_index)
    fruits[start_index..-1].each.with_index(start_index+1) do |fruit, i|
      begin
        puts("#{i}番目")
        fetch_and_set_fruits_detail!(fruit)
      rescue => e
        puts(e)
        puts("fetch detail try agrain")
        sleep(2)
        fetch_fruit_detail_data!(fruits, i)
      end
    end
  end

  def fetch_and_set_fruits_detail!(fruit)
    puts("scrapint #{fruit.name}")
    puts("scrapint #{fruit.page_url}")

    doc = fetch_nokogiri_doc(fruit.page_url)
    current_h2 = nil
    current_h3 = nil

    doc.search('article').first.search('div').first.children.each do |element|
      # h2, h3 が階層構造になっていないので、探索して処理する
      # 次の h2 が現れるまで current_h2 として保持しておき、それで h3 にタグ付けする
      if valid_h2?(element)
        current_h2 = element.text
        fruit.articles << Ingredient::Article.new(current_h2)
      elsif valid_h3(element)
        current_h3 = element.text
        target_article = fruit.articles.find { |article| article.title == current_h2 }
        target_article.sub_categories << Ingredient::SubCategory.new(element.text) if target_article.present?
      elsif valid_h4(element)
        target_article = fruit.articles.find { |article| article.title == current_h2 }
        break if target_article.blank?
        target_sub_category = target_article.sub_categories.find { |sub_category| sub_category.title == current_h3 }
        target_sub_category.contents << element.text if target_sub_category.present?
      end
    end
  end

  def valid_h2?(element)
    return false if element.attributes['class'].blank?
    return false if element.name != 'h2'
    return false if !element.attributes['class'].value.include?("sub-titlle")
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
    return false if !element.attributes['class'].value.include?("doc-f")
    return true
  end
end
