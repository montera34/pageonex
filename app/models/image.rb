class Image < ActiveRecord::Base
	belongs_to :media

	has_many :threadx_images
	has_many :threadxes, :through => :threadx_images

	has_many :image_codes
	has_many :codes, :through => :image_codes

end
