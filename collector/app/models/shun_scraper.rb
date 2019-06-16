require 'open-uri'
require 'nokogiri'
require "csv"

class ShunScraper
  VEGITABLE_URLS = [
    'https://foodslink.jp/syokuzaihyakka/syun/monthly/janvier-ve.htm',
    'https://foodslink.jp/syokuzaihyakka/syun/monthly/fevrier-ve.htm',
    'https://foodslink.jp/syokuzaihyakka/syun/monthly/mars-ve.htm',
    'https://foodslink.jp/syokuzaihyakka/syun/monthly/avril-ve.htm',
    'https://foodslink.jp/syokuzaihyakka/syun/monthly/mai-ve.htm',
    'https://foodslink.jp/syokuzaihyakka/syun/monthly/juin-ve.htm',
    'https://foodslink.jp/syokuzaihyakka/syun/monthly/juillet-ve.htm',
    'https://foodslink.jp/syokuzaihyakka/syun/monthly/aout-ve.htm',
    'https://foodslink.jp/syokuzaihyakka/syun/monthly/septembre-ve.htm',
    'https://foodslink.jp/syokuzaihyakka/syun/monthly/octobre-ve.htm',
    'https://foodslink.jp/syokuzaihyakka/syun/monthly/novembre-ve.htm',
    'https://foodslink.jp/syokuzaihyakka/syun/monthly/decembre-ve.htm'
  ]

  # SEAFOOD_URLS = [
  #   'https://foodslink.jp/syokuzaihyakka/syun/monthly/janvier-fi.htm',
  #   'https://foodslink.jp/syokuzaihyakka/syun/monthly/fevrier-fi.htm',
  #   'https://foodslink.jp/syokuzaihyakka/syun/monthly/mars-fi.htm',
  #   'https://foodslink.jp/syokuzaihyakka/syun/monthly/avril-fi.htm',
  #   'https://foodslink.jp/syokuzaihyakka/syun/monthly/mai-fi.htm',
  #   'https://foodslink.jp/syokuzaihyakka/syun/monthly/juin-fi.htm',
  #   'https://foodslink.jp/syokuzaihyakka/syun/monthly/juillet-fi.htm',
  #   'https://foodslink.jp/syokuzaihyakka/syun/monthly/aout-fi.htm',
  #   'https://foodslink.jp/syokuzaihyakka/syun/monthly/septembre-fi.htm',
  #   'https://foodslink.jp/syokuzaihyakka/syun/monthly/octobre-fi.htm',
  #   'https://foodslink.jp/syokuzaihyakka/syun/monthly/novembre-fi.htm',
  #   'https://foodslink.jp/syokuzaihyakka/syun/monthly/decembre-fi.htm'
  # ]

  VEGITABLE_IMAGE_URL_BASE = "https://img01.plus-server.net/www.foodslink.jp/syokuzaihyakka/syun"
  VEGITABLE_DETAIL_URL_BASE = "https://foodslink.jp/syokuzaihyakka/syun"

  HEADER = ['category', 'name', 'image_url', 'page_url', 'articles_json', 'shun_array']

  def run
    start_index = ENV['START_INDEX'].present? ? ENV['START_INDEX'].to_i : 0
    begin
      vegitables = fetch_vegitables
      vegitables.uniq! { |item| item.name }
      puts("#{vegitables.count}件のデータ取得を開始します")
    rescue => e
      puts(e)
      puts("fetch urls try again")
      vegitables = fetch_vegitables
    end

    # vegitables に値をセットする（不自然なインターフェースだけど後で直す）
    fetch_detail_data!(vegitables, start_index)
    CSV.open('vegitable.csv', 'w') do |csv|
      csv << HEADER
      vegitables.each do |vegitable|
        csv << ['vegitable', vegitable.name, vegitable.image_url, vegitable.page_url, vegitable.articles.to_json, vegitables.first.shun_array]
      end
    end
  end

  def fetch_detail_data!(vegitables, start_index)
    vegitables[start_index..-1].each.with_index(start_index+1) do |vegitable, i|
      begin
        puts("#{i}番目")
        fetch_and_set_vegitable_detail!(vegitable)
      rescue => e
        puts(e)
        puts("fetch detail try agrain")
        sleep(2)
        fetch_detail_data!(vegitables, i)
      end
    end
  end

  def fetch_nokogiri_doc(url)
    charset = nil
    opt = {}
    opt['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/531.37 (KHTML, like Gecko) Chrome/42.0.2311.135 Safari/537.37 Edge/12.<OS build number>'
    html = open(url, opt) do |f|
      charset = f.charset
      f.read
    end
    doc = Nokogiri::HTML.parse(html, nil, charset)
  end

  def fetch_and_set_vegitable_detail!(vegitable)
    puts("scrapint #{vegitable.name}")
    puts("scrapint #{vegitable.page_url}")

    doc = fetch_nokogiri_doc(vegitable.page_url)
    current_h2 = nil
    current_h3 = nil

    calendar_element = doc.search('#calendar').first
    if calendar_element.present?
      calendar_element.search('td').each_with_index do |element, i|
        if element.attributes.present?
          vegitable.shun_array[i] = true
        else
          vegitable.shun_array[i] = false
        end
      end
    end

    doc.search('article')[0].children.each do |element|
      # h2, h3 が階層構造になっていないので、探索して処理する
      # 次の h2 が現れるまで current_h2 として保持しておき、それで h3 にタグ付けする
      if valid_h2?(element)
        current_h2 = element.text
        vegitable.articles << Ingredient::Article.new(current_h2)
      elsif valid_h3(element)
        current_h3 = element.text
        target_article = vegitable.articles.find { |article| article.title == current_h2 }
        target_article.sub_categories << Ingredient::SubCategory.new(element.text) if target_article.present?
      elsif element.attributes['class'].present? && element.name == 'p' && element.attributes['class'].value = 'doc'
        target_article = vegitable.articles.find { |article| article.title == current_h2 }
        break if target_article.blank?
        target_sub_category = target_article.sub_categories.find { |sub_category| sub_category.title = current_h3 }
        target_sub_category.contents << element.text if target_sub_category.present?
      end
    end
  end

  def fetch_vegitables
    vegitables = []
    VEGITABLE_URLS.each do |url|
      doc = fetch_nokogiri_doc(url)
      doc.search('.monthlyimagebox').each do |element|
        vegitable = Ingredient.new
        begin
          vegitable.name = element.search('a').text
          vegitable.image_url = VEGITABLE_IMAGE_URL_BASE + element.search('img').first.attributes["src"].value.remove('..')
          vegitable.page_url = VEGITABLE_DETAIL_URL_BASE + element.search('a').first.attributes['href'].value.remove('..')
          vegitables << vegitable
        rescue => e
          print(e)
        end
      end
    end
    vegitables
  end

  def valid_h2?(element)
    return false if element.attributes['class'].blank?
    return false if element.name != 'h2'
    return false if element.attributes['class'].value != "sab-title"
    return false if element.text.include?('写真')
    return false if element.text.include?('画像')
    return true
  end

  def valid_h3(element)
    return false if element.attributes['class'].blank?
    return false if element.attributes['class'].value != "midashigreen" && element.attributes['class'].value != "midashiblue"
    return true
  end
end
