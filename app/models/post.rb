class Post < ActiveRecord::Base
  belongs_to :category
  has_and_belongs_to_many :tags
  
  validates_presence_of :title, :body
  
  cattr_reader :per_page
  @@per_page = 10
end
