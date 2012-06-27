class CreateHighlightedAreas < ActiveRecord::Migration
  def change
    create_table :highlighted_areas do |t|
      t.integer :image_id
      t.integer :user_id
      t.integer :threadx_image_id

      t.timestamps
    end
  end
end
