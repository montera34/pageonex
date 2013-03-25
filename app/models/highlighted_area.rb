class HighlightedArea < ActiveRecord::Base
	has_many :areas
	belongs_to :code
	belongs_to :user
	belongs_to :image
	
	def threadx
		code.threadx if not code.nil?
	end
	
	def self.by_image(image)
		where(:image_id => image.id)
	end
	
	def self.by_threadx(threadx)
		where(:code_id => threadx.code_ids)
	end
	
	def self.by_code(code)
		where(:code_id => code.id)
	end
	
	def area
		areas.first.width * areas.first.height
	end
end
