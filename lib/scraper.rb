require "fileutils"
require "open-uri"
# RMagick gem is used to convert pdf file into images in the elpais scraper, to get the images size for the other scraper
require "image_size"

class Scraper

	KIOSKO_BASE_URL = "http://img.kiosko.net/"

	def self.use_local_images
		Pageonex::Application.config.use_local_images
	end

	# test like this in the rails console: 
	#   Scraper::scrape_images(Date.today-1, Date.today, [Media.first])
	def self.scrape_images(start_date , end_date, media_list)

		images = []

		# create any local caching dirs that you need to
		if Scraper.use_local_images
			kiosko_image_dir = "app/assets/images/kiosko"
			FileUtils.mkdir kiosko_image_dir unless File.directory? kiosko_image_dir
			media_list.each do |media|
				local_image_dir = "app/assets/images/kiosko/" + media.name
				FileUtils.mkdir local_image_dir unless File.directory? local_image_dir
			end
		end

		media_list.each do |media|
			(start_date..end_date).map do |date|

				img = Image.find_by_media_id_and_publication_date(media.id, date)
				if img==nil	# ensure only one entry per front page in the images table
					img = Image.new
					img.source_url = Scraper::KIOSKO_BASE_URL + date.to_formatted_s(:kiosko_file_datestamp) + "/#{media.country_code}/#{media.name}.750.jpg"
					img.publication_date = date
					img.media_id = media.id
					img.image_name = media.name + "-" + img.publication_date.to_formatted_s(:file_datestamp)
					if Scraper.use_local_images
						img.local_path = 'kiosko/' + media.name + "/" + img.image_name + ".jpg"
						full_local_path = "app/assets/images/" + img.local_path
						begin
							File.open(full_local_path, "wb") { |f| f.write(open(img.source_url).read) }
							File.open(full_local_path,"rb") do |f|
								size_info = ImageSize.new(f.read).get_size
								img.size = "#{size_info[0]}x#{size_info[1]}"
							end
						rescue
							img.local_path = '404.jpg'
							img.size = '750x951'
						end
					else
						img.size = '750x951' #!!this value of pixels is 'hard coded' so it gives wrong values for long newspapers
					end
					img.save
				end
				images << img

			end
		end

		images

	end

end


