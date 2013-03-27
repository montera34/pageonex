class Image < ActiveRecord::Base
	belongs_to :media

	has_many :highlighted_areas
	
	default_scope order("publication_date ASC, media_id ASC")

	before_save :check_if_missing
	
	def self.by_media(media_ids)
		where(:media_id => media_ids)
	end
	
	def self.by_date(dates)
		where(:publication_date => dates)
	end
	
	def self.publication_date
		select('publication_date').uniq.map { |elt| elt.publication_date }
	end

	private

		# Backup strategy: default the "missing" column smartly if it isn't filled in 
		# (even though the scraper should have filled it in)
		def check_if_missing
			if self.missing.nil?
				if Pageonex::Application.config.use_local_images
					self.missing = self.local_path.nil?
				else 
					self.missing = self.source_url.nil?
				end
			end
		end

end
