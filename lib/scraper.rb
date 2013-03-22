require "fileutils"
require "open-uri"
# RMagick gem is used to convert pdf file into images in the elpais scraper, to get the images size for the other scraper
require "RMagick"

class Scraper

	KIOSKO_BASE_URL = "http://img.kiosko.net/"

	def self.use_local_images
		Pageonex::Application.config.use_local_images
	end

	def self.get_issues(start_date , end_date, newspapers_names)

		# create any local caching dirs that you need to
		if Scraper.use_local_images
			kiosko_image_dir = "app/assets/images/kiosko"
			FileUtils.mkdir kiosko_image_dir unless File.directory? kiosko_image_dir
			newspapers_names.each do |country, newspaper_list|
				newspaper_list.each do |newspaper_name|
					newspaper_local_image_dir = Media::local_image_path newspaper_name
					FileUtils.mkdir newspaper_local_image_dir unless File.directory? newspaper_local_image_dir 
				end
			end
		end

		@@newspapers_images = {}
		# URIs of the issues 
		newspapers_issues_info = Scraper.build_kiosko_issues(start_date, end_date, newspapers_names)
		#newspapers_issues_paths = Scraper.build_newyork_times_issues(year, month, start_day, end_day)
		#newspapers_issues_paths = Scraper.build_elpais_issues(year, month, start_day, end_day)

		Scraper.scrape newspapers_issues_info

		@@newspapers_images
	end

	# scrape method take the URIs of the issues and scrape them
	def self.scrape(newspapers_issues_info)

		newspapers_issues_info.each do |info|
			begin
				
				if Scraper.use_local_images
					open(path) do |source| 
						# pass to save method the path of the issue and the issue it self
						Scraper.save_kiosko_issues info
						#Scraper.save_newyork_times_issues path, source
						#Scraper.save_elpais_issues path, source
					end
				else
					# live scraping for deployed version on heroku
					Scraper.save_kiosko_issues info
				end

			rescue => e
				newspaper_name = info[:newspaper_name]
				pub_date = info[:date]
				@@newspapers_images[newspaper_name.split(".")[0] +"-"+ pub_date] = { publication_date: pub_date, media: newspaper_name.split(".")[0], local_path: "404.jpg"}
				puts e.message + " => " + path
			end
		end

	end

	# first version paramters(year, month, start_day, end_day)
	def self.issues_dates(start_date, end_date)
		(start_date..end_date).map { |d| d.to_formatted_s(:kiosko_frontpage_image) }
	end

	# building the URIs of the issues based on the passed dates
	# this script able to scrape back to 2008, 2009, and 2010 but most of the newspaper dosen't exsit in this years, and it also covers 2011, 2012 
	# first version params
	def self.build_kiosko_issues(start_date, end_date, kiosko_newspapers)

		issues = Scraper.issues_dates(start_date, end_date)

		newspapers_issues = []
		newspapers_issues_info = []

		# constracting the full URI of each image
		kiosko_newspapers.each do |country, newspaper_list|
			newspaper_list.each do |newspaper_name| 
				issues.each do |issue| 
					newspapers_issues_info << { 
						:url => Scraper::KIOSKO_BASE_URL + issue + "/#{country}/#{newspaper_name}.750.jpg",
						:newspaper_name => newspaper_name,
						:date => issue,
						:country => country
					}
				end
			end
		end

		newspapers_issues_info
	end

	# save each image in it's place with name contains the date if the issue
	def self.save_kiosko_issues(info)

		newspaper_name = info[:newspaper_name]

		if Scraper.use_local_images
			open("app/assets/images/kiosko/#{path.split("/")[-1].split(".")[0]}/" + "#{path.split('/')[-3]}-#{path.split('/')[-4]}-#{path.split('/')[-5]}-" + newspaper_name ,"wb") do |file|
		 		file.write(source.read())
		 		pub_date = "#{path.split('/')[-3]}-#{path.split('/')[-4]}-#{path.split('/')[-5]}"
				@@newspapers_images[newspaper_name.split(".")[0] +"-"+ pub_date] = {publication_date: pub_date, media: newspaper_name.split(".")[0], local_path: "/kiosko/#{path.split("/")[-1].split(".")[0]}/" + "#{pub_date}-" + newspaper_name}
				puts "done => #{path.split('/')[-3]}-#{path.split('/')[-4]}-#{path.split('/')[-5]}-" + newspaper_name
		 	end
		else
			# live scraping for deployed version on heroku
			# resolution of the produced image  is [750x1072]
			pub_date = info[:date]
			@@newspapers_images[newspaper_name.split(".")[0] +"-"+ pub_date] = {publication_date: pub_date, media: newspaper_name.split(".")[0], local_path: info[:url]}
			puts "done => " + pub_date + "-" + newspaper_name
		end

	end

	# building the URIs of the issues based on the passed dates
	def self.build_newyork_times_issues(year, month, start_day, end_day)

		FileUtils.mkdir "app/assets/images/newyork_times" unless File.directory? "app/assets/images/newyork_times" 

		domain = "http://www.nytimes.com/images/"

		newspapers_issues_paths = []

		issues = Scraper.issues_dates year, month, start_day, end_day

		issues.each do |issue| 
			newspapers_issues_paths << domain + issue + "app/assets/images/nytfrontpage/scan.jpg"
		end

		newspapers_issues_paths
	end

	# save each image in it's place with name contains the date if the issue
	def self.save_newyork_times_issues(path, source)

		# resolution of the produced image  is [348x640]
		open("app/assets/images/newyork_times/" + "#{path.split('/')[-3]}-#{path.split('/')[-4]}-#{path.split('/')[-5]}" ,"wb") do |file|
			file.write(source.read())
			puts "done => #{path.split('/')[-3]}-#{path.split('/')[-4]}-#{path.split('/')[-5]}"
		end

	end

	# building the URIs of the issues based on the passed dates
	def self.build_elpais_issues(year, month, start_day, end_day)

		# scrape a pdf from http://elpais.com/ and convert it to png 
		FileUtils.mkdir "app/assets/images/elpais" unless File.directory? "app/assets/images/elpais" 

		# first issue available date is 2012/03/01
		issues = Scraper.issues_dates year, month, start_day, end_day

		newspapers_issues_paths = []

		issues.each do |d| 
			newspapers_issues_paths << "http://srv00.epimg.net/pdf/elpais/1aPagina/" + d[0..7] + "ep-" + d[0..3] + d[5..6] + d[8..11] + ".pdf"
		end

		newspapers_issues_paths
	end

	# convert each passed pdf file to jpg and save this image in it's place with name contains the date if the issue
	def self.save_elpais_issues(path, source)

		file_name = "#{path.split('/')[-3]}-#{path.split('/')[-2]}-#{path.split('/')[-1][9..10]}"

		open("app/assets/images/elpais/" + file_name ,"w+b") do |file|
			file.write(source.read())
			issue_pdf = Magick::ImageList.new("app/assets/images/elpais/#{file_name}")
			# resolution of the produced image  is [765x1133]
			issue_pdf.write "app/assets/images/elpais/#{file_name}.jpg"
			File.delete "app/assets/images/elpais/#{file_name}"
			puts "done => #{file_name}"
		end

	end

end


