class Image < ActiveRecord::Base
	belongs_to :media

	has_many :highlighted_areas
	
	default_scope order("publication_date ASC, media_id ASC")
	
	def self.by_media(media_ids)
		where(:media_id => media_ids)
	end
	
	def self.by_date(dates)
		where(:publication_date => dates)
	end
end
