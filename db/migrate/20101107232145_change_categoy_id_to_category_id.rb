class ChangeCategoyIdToCategoryId < ActiveRecord::Migration
  def self.up
    rename_column :posts, :categoy_id, :category_id
  end

  def self.down
    rename_column :posts, :category_id, :categoy_id
  end
end
