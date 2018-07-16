class CreateTaxonomyOptions < ActiveRecord::Migration
  def change
    create_table :taxonomy_options do |t|
      t.string :value
      t.integer :taxonomy_id

      t.timestamps
    end
  end
end
