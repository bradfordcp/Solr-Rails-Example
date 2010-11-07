class AddCategoryIdToPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :categoy_id, :string
  end

  def self.down
    remove_column :posts, :categoy_id
  end
end
