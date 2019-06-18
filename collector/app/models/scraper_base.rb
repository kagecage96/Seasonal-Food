require 'open-uri'
require 'nokogiri'
require "csv"

class ScraperBase
  IMAGE_URL_BASE = "https://img01.plus-server.net/www.foodslink.jp/syokuzaihyakka/syun"
  DETAIL_URL_BASE = "https://foodslink.jp/syokuzaihyakka/syun"

  HEADER = ['category', 'name', 'image_url', 'page_url', 'articles_json', 'shun_array']

  def fetch_nokogiri_doc(url)
    uri = URI.encode(url)
    uri = URI.parse(uri)

    charset = nil
    opt = {}
    opt['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/531.37 (KHTML, like Gecko) Chrome/42.0.2311.135 Safari/537.37 Edge/12.<OS build number>'
    html = open(uri, opt) do |f|
      charset = f.charset
      f.read
    end
    doc = Nokogiri::HTML.parse(html, nil, charset)
  end
end
