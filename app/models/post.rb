class Post < ActiveRecord::Base
  belongs_to :category
  has_and_belongs_to_many :tags
  
  validates_presence_of :title, :body
  
  cattr_reader :per_page
  @@per_page = 10
  searchable do
    text :title, :default_boost => 2
    text :body
    integer :category_id, :references => Category
    integer :tag_ids, :references => Tag, :multiple => true
    time :created_at
    boost { created_at > (Time.now - 1.day) ? 2.0 : 1.0 } 
  end
  
end
