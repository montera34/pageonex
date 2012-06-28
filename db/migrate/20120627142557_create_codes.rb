class CreateCodes < ActiveRecord::Migration
  def change
    create_table :codes do |t|
      t.string :code_text
      t.integer :threadx_id

      t.timestamps
    end
  end
end
