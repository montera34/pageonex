class HighlightedArea < ActiveRecord::Base
	has_many :areas
	belongs_to :threadx_image
	belongs_to :user
end
