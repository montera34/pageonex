class Code < ActiveRecord::Base
	belongs_to :threadx
	has_many :highlighted_areas

	has_many :image_codes
	has_many :images, :through => :image_codes
end
