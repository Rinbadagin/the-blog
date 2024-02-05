class RenameColumnsAuthor < ActiveRecord::Migration[7.1]
  def change
    rename_column :guestbook_entries, :author, :name
  end
end
