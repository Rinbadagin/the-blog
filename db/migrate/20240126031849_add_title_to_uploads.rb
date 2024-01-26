class AddTitleToUploads < ActiveRecord::Migration[7.1]
  def change
    add_column :uploads, :title, :string
  end
end
