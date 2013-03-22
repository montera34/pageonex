require "fileutils"
require "open-uri"
# RMagick gem is used to convert pdf file into images in the elpais scraper, to get the images size for the other scraper
require "RMagick"

class Scraper

	KIOSKO_BASE_URL = "http://img.kiosko.net/"

	def self.use_local_images
		Pageonex::Application.config.use_local_images
	end

	def self.create_images(start_date , end_date, media_list)

		images = []

		# create any local caching dirs that you need to
		if Scraper.use_local_images
			kiosko_image_dir = "app/assets/images/kiosko"
			FileUtils.mkdir kiosko_image_dir unless File.directory? kiosko_image_dir
			media_list.each do |media|
				FileUtils.mkdir media.local_image_dir unless File.directory? media.local_image_dir
			end
		end

		media_list.each do |media|
			(start_date..end_date).map do |date|

				kiosko_url = Scraper::KIOSKO_BASE_URL + date.to_formatted_s(:kiosko_file_datestamp) + "/#{media.country_code}/#{media.name}.750.jpg"
				puts kiosko_url
				#TODO check if it exists first
				img = Image.new
				img.publication_date = date
				img.media_id = media.id
				img.image_name = media.name + "-" + img.publication_date.to_formatted_s(:file_datestamp)
				if Scraper.use_local_images
					img.local_path = media.local_image_dir + "/" + img.image_name
					File.open(img.local_path, "wb") { |f| f.write(open(kiosko_url).read) }
					size_info = Magick::ImageList.new(local_path)[0]
					img.size = "#{size_info.columns}x#{size_info.rows}"
				else
					img.local_path = kiosko_url
					img.size = '750x951' #!!this value of pixels is 'hard coded' so it gives wrong values for long newspapers
				end
				img.save
				images << img

			end
		end

		images

	end

end


