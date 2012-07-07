class RenameThreadxImageIdToCodeIdFromHighlightedArea < ActiveRecord::Migration
  def change
    rename_column :highlighted_areas, :threadx_image_id, :code_id
  end
end
