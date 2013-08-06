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
		where(:missing=>false)
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

	def thumbnail_local_path width=80, generate=true
	 	path = self.local_path.chomp(File.extname(self.local_path))+'-thumb-'+width.to_s+'.jpg'
	 	self.thumbnail width if generate
		path
	end

	# return a Magick img object that is a thumbnail (caches to disk) - nil if image missing or messed up
	def thumbnail width, path=nil
		return nil unless File.exists? self.full_local_path # bail if there is no image
		if path==nil
			thumb_file_path = File.join 'app','assets','images',self.thumbnail_local_path(width,false)
		else 
			thumb_file_path = File.join 'app','assets','images', path
		end
		return Magick::Image.read(thumb_file_path).first if File.exists?(thumb_file_path) and File.size?(thumb_file_path)
		# if the thumb doesn't exist then generate it
		img_thumb = nil
		return img_thumb if not File.size? self.full_local_path
		begin
			img = Magick::Image.read(self.full_local_path).first
			scale = width.to_f / img.columns.to_f
			img_thumb = img.thumbnail(scale)
			img_thumb.write thumb_file_path
		rescue Magick::ImageMagickError=>e
			logger.error "Image Empty Error in image.thumbnail: #{e}"
		end
		return img_thumb
	end

	def local_path
		File.join('kiosko', self.media.image_directory_name, self.image_name + ".jpg")
	end

	def download		
		if Pageonex::Application.config.use_local_images
			# make the media dir if you need to
			self.media.create_image_directory
			# try to fetch the image
			begin
				File.open(self.full_local_path, "wb") { |f| f.write(open(self.source_url).read) }
				if File.size? self.full_local_path
					# TODO we should check the file size here to see if it is zero (raise exception if it is)
					File.open(self.full_local_path,"rb") do |f|
						size_info = ImageSize.new(f.read).get_size
						self.size = "#{size_info[0]}x#{size_info[1]}"
					end
					self.missing = false 
				else 
					self.size = '750x951'
					logger.debug "Image Download Failed:#{id}: got a zero size image for #{source_url}"
				end
			rescue Exception => e  
				# image doesn't exist on their server :-(
				logger.debug "Image Download Failed:#{id}: couldn't find image at #{source_url} (#{e.message})"
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
