class AddParentIdToThreads < ActiveRecord::Migration
  def change
    add_column :threadxes, :parent_id, :integer
  end
end
