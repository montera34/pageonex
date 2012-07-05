class AddColorToCode < ActiveRecord::Migration
  def change
    add_column :codes, :color, :string

  end
end
