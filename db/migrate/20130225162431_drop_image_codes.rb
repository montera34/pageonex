class DropImageCodes < ActiveRecord::Migration
  def up
    drop_table :image_codes
  end

  def down
    create_table(:threadx_images) do |t|
      t.integer  "image_id"
      t.integer  "code_id"
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end
  end
end
