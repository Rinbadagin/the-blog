class AddDescriptionToUploads < ActiveRecord::Migration[7.1]
  def change
    add_column :uploads, :description, :string
  end
end
