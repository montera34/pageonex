class CreateThreadxTaxonomies < ActiveRecord::Migration
  def change
    create_table :threadx_taxonomies do |t|
      t.integer :threadx_id
      t.integer :taxonomy_id

      t.timestamps
    end
  end
end