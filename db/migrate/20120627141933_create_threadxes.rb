class CreateThreadxes < ActiveRecord::Migration
  def change
    create_table :threadxes do |t|
      t.string :thread_name
      t.string :thread_display_name
      t.date :start_date
      t.date :end_date
      t.text :description
      t.string :category
      t.string :status
      t.integer :owner_id 

      t.timestamps
    end
  end
end
