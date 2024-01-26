class AddVisibilityToArticles < ActiveRecord::Migration[7.1]
  def change
    add_column :articles, :visibility, :boolean
  end
end
