class ThreadxImage < ActiveRecord::Base
	has_many :highlighted_areas
	belongs_to :image
	belongs_to :threadx
	belongs_to :code
end
