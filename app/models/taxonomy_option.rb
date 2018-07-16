class TaxonomyOption < ActiveRecord::Base
  belongs_to :taxonomy
  has_many :taxonomy_classifications, dependent: :destroy

  validates :value, presence: true, uniqueness: { scope: :taxonomy_id }
  validates :taxonomy_id, presence: true
end
