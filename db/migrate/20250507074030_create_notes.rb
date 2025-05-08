class CreateNotes < ActiveRecord::Migration[7.1]
  def change
    create_table :notes do |t|
      t.string :subject
      t.string :body
      t.string :contact
      t.string :homesite
      t.boolean :public

      t.timestamps
    end
  end
end
