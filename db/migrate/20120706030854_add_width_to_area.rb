class AddWidthToArea < ActiveRecord::Migration
  def change
    add_column :areas, :width, :integer

  end
end
