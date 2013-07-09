class RemoveImageLocalPath < ActiveRecord::Migration
  def change
  	remove_column :images, :local_path
  end
end
