require 'csv'

class CollectMekikiUrlScraper < ScraperBase
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
        shun_array = JSON.parse(data["shun_array"])
        articles_jsons = data["articles_json"]
        doc = fetch_nokogiri_doc(page_url)

        if doc.search('.guide-v').present?
          a_tag = doc.search('.guide-v')[0].search('a').find { |element|
            element.text.include?("選び方") || element.text.include?("目利き")
          }
          mekiki_path = a_tag.attributes["href"].value
        elsif doc.search('.guide-fi').present?
          a_tag = doc.search('.guide-fi')[0].search('a').find { |element|
            element.text.include?("選び方") || element.text.include?("目利き")
          }
          mekiki_path = a_tag.attributes["href"].value
        elsif  doc.search('.brownbox').present?
          box_tag = doc.search('.brownbox').find { |box| box.text.include?("選び方") || box.text.include?("目利き") }
          a_tag = box_tag.search('a').find { |element|
            element.text.include?("選び方") || element.text.include?("目利き")
          }
          mekiki_path = a_tag.attributes["href"].value
        end

        mekiki_url = nil
        if mekiki_path.present?
          path_array = page_url.split('/')
          path_array.pop
          mekiki_url = path_array.join('/') + "/" + mekiki_path
        end
        ingredient_array << [category, sub_category_en, sub_category_jp, name, image_url, page_url, articles_jsons, shun_array, mekiki_url]
      rescue => e
        puts "例外 : #{page_url}"
        puts e
        ingredient_array << [category, sub_category_en, sub_category_jp, name, image_url, page_url, articles_jsons, shun_array, nil]
      end
    end

    CSV.open('ingredient.csv','w') do |csv|
      ingredient_array.each do |a|
        csv << a
      end
    end
  end
end
