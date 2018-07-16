class CreateTaxonomyClassifications < ActiveRecord::Migration
  def change
    create_table :taxonomy_classifications do |t|
      t.integer :highlighted_area_id
      t.integer :taxonomy_option_id

      t.timestamps
    end
  end
end

