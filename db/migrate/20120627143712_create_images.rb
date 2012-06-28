class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.date :publication_date
      t.integer :size
      t.string :local_path
      t.integer :media_id

      t.timestamps
    end
  end
end
