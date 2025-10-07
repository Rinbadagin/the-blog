class CreateWebringNodes < ActiveRecord::Migration[7.1]
  def change
    create_table :webring_nodes do |t|
      t.text :description
      t.text :site_link
      t.text :author
      t.boolean :in_the_ring

      t.text :notes

      t.timestamps
    end
  end
end
