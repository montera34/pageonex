class AddThreadxIdToHighlightedArea < ActiveRecord::Migration
  def change
    add_column :highlighted_areas, :threadx_id, :integer

  end
end
