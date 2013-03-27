class AddMissingToImage < ActiveRecord::Migration
  def change
    add_column :images, :missing, :boolean
  end
end
