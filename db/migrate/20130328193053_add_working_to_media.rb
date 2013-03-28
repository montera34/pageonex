class AddWorkingToMedia < ActiveRecord::Migration
  def change
    add_column :media, :working, :boolean, {:default=>true}
  end
end
