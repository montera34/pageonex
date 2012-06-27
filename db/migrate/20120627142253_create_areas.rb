class CreateAreas < ActiveRecord::Migration
  def change
    create_table :areas do |t|
      t.integer :x1
      t.integer :y1
      t.integer :x2
      t.integer :y2
      t.integer :highlighted_area_id

      t.timestamps
    end
  end
end
