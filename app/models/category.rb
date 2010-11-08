class Category < ActiveRecord::Base
  has_many :posts
  searchable do
    text :name
  end
end
