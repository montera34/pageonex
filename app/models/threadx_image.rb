class ThreadxImage < ActiveRecord::Base
	
	belongs_to :image
	belongs_to :threadx
	
end
