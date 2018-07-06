class ThreadxTaxonomy < ActiveRecord::Base
  belongs_to :threadx
  belongs_to :taxonomy

  validates :taxonomy_id, uniqueness: { scope: :threadx_id }
end
