class AddNameToHighlightedArea < ActiveRecord::Migration
  def change
    add_column :highlighted_areas, :name, :string

  end
end
