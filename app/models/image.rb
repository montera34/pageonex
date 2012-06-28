class Image < ActiveRecord::Base
	belongs_to :media
	has_many :threadx_images
end
