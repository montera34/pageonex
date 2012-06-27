class CreateThreadxImages < ActiveRecord::Migration
  def change
    create_table :threadx_images do |t|
      t.integer :threadx_id
      t.integer :image_id
      t.integer :code_id

      t.timestamps
    end
  end
end
