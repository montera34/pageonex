class CreateCodedPages < ActiveRecord::Migration
  def change
    create_table :coded_pages do |t|
      t.integer :threadx_id
      t.integer :user_id
      t.integer :image_id

      t.timestamps
    end
  end
end
