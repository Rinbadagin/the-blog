class CreateGuestbookEntries < ActiveRecord::Migration[7.1]
  def change
    create_table :guestbook_entries do |t|
      t.string :author
      t.string :body
      t.string :home_site
      t.string :contact
      t.boolean :hide_contact_from_public

      t.timestamps
    end
  end
end
