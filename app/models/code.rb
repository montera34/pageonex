class Code < ActiveRecord::Base
	belongs_to :threadx
	has_many :threadx_image
end
