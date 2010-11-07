class CreatePostsTagsTable < ActiveRecord::Migration
  def self.up
    create_table :posts_tags, :force => true do |t|
      t.integer :post_id
      t.integer :tag_id
      t.timestamps
    end
  end

  def self.down
    drop_table :posts_tags
  end
end
