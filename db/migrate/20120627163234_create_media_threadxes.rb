class CreateMediaThreadxes < ActiveRecord::Migration
  def change
    create_table :media_threadxes do |t|
      t.integer :threadx_id
      t.integer :media_id

      t.timestamps
    end
  end
end
