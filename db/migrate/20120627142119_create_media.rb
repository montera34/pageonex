class CreateMedia < ActiveRecord::Migration
  def change
    create_table :media do |t|
      t.string :name
      t.string :country
      t.string :city
      t.string :url

      t.timestamps
    end
  end
end
