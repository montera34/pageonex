class RemoveThreadxIdFromHighlightedArea < ActiveRecord::Migration
  def up
    remove_column :highlighted_area, :threadx_id
  end

  def down
    add_column :highlighted_area, :threadx_id, :integer
  end
end
