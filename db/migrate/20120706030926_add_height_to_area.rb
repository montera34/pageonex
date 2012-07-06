class AddHeightToArea < ActiveRecord::Migration
  def change
    add_column :areas, :height, :integer

  end
end
