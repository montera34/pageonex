class ChangeSizeTypeInImage < ActiveRecord::Migration
	def change
		change_column :images, :size, :string
  end
end
