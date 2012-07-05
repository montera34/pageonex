class AddCodeDescriptionToCode < ActiveRecord::Migration
  def change
    add_column :codes, :code_description, :text

  end
end
