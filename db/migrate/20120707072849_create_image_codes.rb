class CreateImageCodes < ActiveRecord::Migration
  def change
    create_table :image_codes do |t|
      t.integer :image_id
      t.integer :code_id

      t.timestamps
    end
  end
end
