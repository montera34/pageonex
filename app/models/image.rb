require 'RMagick'
require "open-uri"

class Image < ActiveRecord::Base
	belongs_to :media

	has_many :highlighted_areas
	
	default_scope order("publication_date ASC, media_id ASC")

	before_save :check_if_missing
	
	def width
		return size[0..(size.index('x'))].to_i
	end
	
	def height
		length = size.length - size.index('x') - 1;
		return size[-1*length, length].to_i
	end
	
	def self.codeable
		where("local_path != '404.jpg'").where(:missing=>false)
	end
	
	def self.by_media(media_ids)
		where(:media_id => media_ids)
	end
	
	def self.by_date(dates)
		where(:publication_date => dates)
	end
	
	def self.publication_date
		select('publication_date').uniq.map { |elt| elt.publication_date }
	end

	# return a Magick img object that is a thumbnail (caches to disk)
	def thumbnail width
		return nil unless File.exists? self.full_local_path # bail if there is no image
		thumb_file_path = self.full_local_path.chomp(File.extname(self.full_local_path) )+'-thumb-'+width.to_s+'.jpg'
		return Magick::Image.read(thumb_file_path).first if File.exists? thumb_file_path
		# if the thumb doesn't exist then generate it
		img = Magick::Image.read(self.full_local_path).first
		scale = width.to_f / img.columns.to_f
		img_thumb = img.thumbnail(scale)
		img_thumb.write thumb_file_path
		return img_thumb
	end

	def download		
		if Pageonex::Application.config.use_local_images
			# make the media dir if you need to
			self.media.create_image_directory
			# try to fetch the image
			self.local_path = File.join('kiosko',self.media.name,image_name + ".jpg")
			begin
				File.open(self.full_local_path, "wb") { |f| f.write(open(self.source_url).read) }
				File.open(self.full_local_path,"rb") do |f|
					size_info = ImageSize.new(f.read).get_size
					self.size = "#{size_info[0]}x#{size_info[1]}"
				end
				self.missing = false
			rescue Exception => e  
				# image doesn't exist on their server :-(
				logger.debug "Image Download Failed:#{id}: couldn't find image at #{source_url} (#{e.message})"
				self.local_path = '404.jpg'
				self.size = '750x951'
				self.missing = true
			end
		else 
			url = URI.parse(self.source_url)
			request = Net::HTTP.new(url.host, url.port)
			response = request.request_head(url.path)
			self.size = '750x951' #!!this value of pixels is 'hard coded' so it gives wrong values for long newspapers
			self.missing = (response.code != "200")
		end
		!missing
	end

	def full_local_path
		File.join('app','assets','images', self.local_path)
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
