class HighlightedArea < ActiveRecord::Base
	has_many :areas
	belongs_to :code
	belongs_to :user
	belongs_to :image
end
