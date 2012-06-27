class CreateThreadxCollaborators < ActiveRecord::Migration
  def change
    create_table :threadx_collaborators do |t|
      t.integer :threadx_id
      t.integer :user_id

      t.timestamps
    end
  end
end
