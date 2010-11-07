class RemoveIdFromPostsTags < ActiveRecord::Migration
  def self.up
    remove_column :posts_tags, :id
  end

  def self.down
    add_column :posts_tags, :id, :integer
  end
end
