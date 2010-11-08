class Post < ActiveRecord::Base
  belongs_to :category
  has_and_belongs_to_many :tags
  
  validates_presence_of :title, :body
  searchable do
    text :title, :default_boost => 2
    text :body
    integer :category_id, :references => Category
    time :create_at
    boost { created_at > (Time.now - 1.day) ? 2.0 : 1.0 } 
  end
  
end
