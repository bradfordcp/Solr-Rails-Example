class Post < ActiveRecord::Base
  belongs_to :category
  has_and_belongs_to_many :tags
  
  validates_presence_of :title, :body
  
  cattr_reader :per_page
  @@per_page = 10

  # Generates a hash to send to the solr server using the solr-ruby gem
    def to_solr
      sol = {}

      sol[:id] = "#{self.class}:#{self.id}"
      sol[:type] = self.class
      sol[:title] = self.title
      sol[:category] = self.category.name
      sol[:body] = self.body
      sol[:tidy_body] = HTML::FullSanitizer.new.sanitize(self.description)[0..250]
      
      tags = []
      self.tags.each do |tag|
        tags << tag.name
      end
      sol[:tags] = tags

      return sol
    end
end
