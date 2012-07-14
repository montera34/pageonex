class ThreadsController < ApplicationController
	before_filter :authenticate_user!, :except => :show

	def index
		@threads = current_user.owned_threads
	end

	def create
		@thread = Threadx.new
		@thread.update_attributes!(params[:threadx])
		@thread.thread_name = params[:threadx]["thread_display_name"].sub(' ', '_')


		# this array is made to passed to Scraper.get_issues method, because this method accept the specific format of newspapers names as the following
		# {"es" => ["elpais", "abc"], "de" => ["faz", "bild"], "fr" => ["lemonde", "lacroix"], "it" => ["corriere_della_sera", "ilmessaggero"], "uk" => ["the_times", ],"us" => ["wsj", "newyork_times", "usa_today"]}
		# city attribute holds the country code like {"es", "de", ...}
		# name attribute holds the name of the newspaper {"elpais", "abc", ...}
		newspapers_names = {}

		number_of_newspapers = params[:media_count].to_i
		number_of_newspapers.downto(1) do |n|
			_media = Media.find(params["media#{n}"])
			@thread.media << _media
			if newspapers_names[_media.city] != nil
				newspapers_names[_media.city] << _media.name 
			else
				newspapers_names[_media.city] = []
				newspapers_names[_media.city] << _media.name
			end

		end

		# create object for each code submited
		number_of_topics = params[:topic_count].to_i
		number_of_topics.downto(1) do |n|
			Code.create!({:code_text => params["topic_name_#{n}"], :code_description => params["topic_description_#{n}"],:color => params["topic_color_#{n}"],:threadx_id => @thread.id})
		end

		# array of object refers to scraped images
		images = []

		# passes dates and formated newspapers_names array, and the return is a hash contains info about each images(publication_date, media, local_path)
		newspapers_images = Scraper.get_issues(@thread.start_date.year,@thread.start_date.month,@thread.start_date.day,@thread.end_date.day, newspapers_names)

		newspapers_images.each do |image_name, image_info|
			# search if the image dose not exsit, it create an object for this image 
			if ( (image = Image.find_by_image_name image_name) == nil)
				image_info["image_name"] = image_name
				media = Media.find_by_name(image_info[:media])

				image = Image.create!({ image_name: image_info["image_name"],publication_date: image_info[:publication_date], local_path: image_info[:local_path], media_id: media.id})
				
				images << image
			# otherwise it find the image, and add to the array
			else
				image = Image.find_by_image_name(image_name)
				images << image
			end
		end

		# add reference to the scraped images to the thread
		@thread.images << images

		# specifying the owner, because there is a collaborators (related to Intercoder)
		@thread.owner_id = current_user.id
		@thread.save!

		redirect_to "/threads/#{@thread.thread_name}/coding"
	end

	def new
		@media = []
		@thread = Threadx.new
		Media.all.each do |newspaper|
			newspaper.name = "#{newspaper.country} - #{newspaper.display_name}"
			@media << newspaper
		end
		
	end

	def edit
		@thread = Threadx.find_by_thread_name params[:id]
	end

	def update
		@thread = Threadx.find_by_thread_name params[:id]
		@thread.update_attributes(params[:threadx])
		@thread.thread_name = params[:threadx]["thread_display_name"].sub(' ', '_')
		@thread.save!
		redirect_to "/threads/#{@thread.thread_name}/display"
	end

	def show
		@thread = Threadx.find_by_thread_name params[:id]
		redirect_to "/threads/#{@thread.thread_name}/display"
	end

end
