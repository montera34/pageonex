class ImageCode < ActiveRecord::Base
	belongs_to :image
	belongs_to :code
end
