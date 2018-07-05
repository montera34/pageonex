class TaxonomyOption < ActiveRecord::Base
  belongs_to :taxonomy

  validates :value, presence: true, uniqueness: { scope: :taxonomy_id }
  validates :taxonomy_id, presence: true
end
