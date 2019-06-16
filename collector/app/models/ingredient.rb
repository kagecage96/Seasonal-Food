class Ingredient
  attr_accessor :name, :image_url, :page_url, :articles, :shun_array
  def initialize
    @articles = []
    @shun_array = Array.new(12, false)
  end

  class Article
    attr_accessor :title, :sub_categories

    def initialize(title)
      @title = title
      @sub_categories = []
    end
  end

  class SubCategory
    attr_accessor :title, :contents

    def initialize(title)
      @title = title
      @contents = []
    end
  end
end
