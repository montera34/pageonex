class Code < ActiveRecord::Base
	belongs_to :threadx
	has_many :highlighted_areas
end
