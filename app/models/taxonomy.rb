class Taxonomy < ActiveRecord::Base
  has_many :taxonomy_options, dependent: :destroy

  validates :name, presence: true, uniqueness: true
end
