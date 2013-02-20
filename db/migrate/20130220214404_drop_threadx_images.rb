class DropThreadxImages < ActiveRecord::Migration
  def up
    drop_table :threadx_images
  end

  def down
    create_table(:threadx_images) do |t|
      t.integer  "threadx_id"
      t.integer  "image_id"
      t.integer  "code_id"
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end
  end
end
