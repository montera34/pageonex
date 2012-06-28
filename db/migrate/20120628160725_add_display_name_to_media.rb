class AddDisplayNameToMedia < ActiveRecord::Migration
  def change
    add_column :media, :display_name, :string

  end
end
