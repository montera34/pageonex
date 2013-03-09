class FixColumnMediaName < ActiveRecord::Migration
  def change
    rename_column :media, :city, :country_code
  end
end
