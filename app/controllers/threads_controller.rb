class ThreadsController < ApplicationController
	before_filter :authenticate_user!

	def index
		@threads = current_user.owned_threads
	end

	def create

		@thread = Threadx.new(params[:threadx])
		@thread.thread_name = params[:threadx]["thread_display_name"].split(' ').join('_')
		@thread.owner_id = current_user.id
		@thread.status = params[:status]
		# @thread.update_attributes(params[:threadx])
		
		# existing_thread = current_user.owned_threads.find_by_thread_display_name params[:threadx]["thread_display_name"]
		 
		if @thread.valid? && params[:media] != nil && params["topic_name_1"] != "" 

			
			# this array is made to passed to Scraper.get_issues method, because this method accept the specific format of newspapers names as the following
			# {"es" => ["elpais", "abc"], "de" => ["faz", "bild"], "fr" => ["lemonde", "lacroix"], "it" => ["corriere_della_sera", "ilmessaggero"], "uk" => ["the_times", ],"us" => ["wsj", "newyork_times", "usa_today"]}
			# city attribute holds the country code like {"es", "de", ...}
			# name attribute holds the name of the newspaper {"elpais", "abc", ...}
			newspapers_names = {}

			# number_of_newspapers = params[:media_count].to_i
			# number_of_newspapers.downto(1) do |n|
			# 	_media = Media.find(params["media#{n}"])
			# 	@thread.media << _media
			# 	if newspapers_names[_media.city] != nil
			# 		newspapers_names[_media.city] << _media.name 
			# 	else
			# 		newspapers_names[_media.city] = []
			# 		newspapers_names[_media.city] << _media.name
			# 	end

			# end

			media = params[:media]
			media.each do |m|
				_media = Media.find(m)
				@thread.media << _media
				if newspapers_names[_media.city] != nil
					newspapers_names[_media.city] << _media.name 
				else
					newspapers_names[_media.city] = []
					newspapers_names[_media.city] << _media.name
				end
			end

			# create object for each code submited
			# number_of_topics = params[:topic_count].to_i
			# number_of_topics.downto(1) do |n|
			# 	Code.create!({:code_text => params["topic_name_#{n}"], :code_description => params["topic_description_#{n}"],:color => params["topic_color_#{n}"],:threadx_id => @thread.id})
			# end

			# create object for each code submited
			code = Code.create!({:code_text => params["topic_name_1"], :code_description => params["topic_description_1"],:color => params["topic_color_1"]})


			# array of object refers to scraped images
			images = []

			# passes dates and formated newspapers_names array, and the return is a hash contains info about each images(publication_date, media, local_path)
			newspapers_images = Scraper.get_issues(@thread.start_date.year,@thread.start_date.month,@thread.start_date.day,@thread.end_date.day, newspapers_names)

			newspapers_images.each do |image_name, image_info|
				# search if the image dose not exsit, it create an object for this image 
				if ( (image = Image.find_by_image_name image_name) == nil)
					image_info["image_name"] = image_name
					media = Media.find_by_name(image_info[:media])

					if image_info[:local_path] != "404.jpg"
						# image_size = Magick::ImageList.new("app/assets/images" + image_info[:local_path])[0]
						# image_size = "#{image_size.columns}x#{image_size.rows}"

						# for the online heroku beta
						
							# puts(image_info[:local_path])
							# begin
							# 	image_size = Magick::ImageList.new(image_info[:local_path])[0]
							# 	image_size = "#{image_size.columns}x#{image_size.rows}"
							# rescue => e
							# 	image_size="750x951"
							# end
							image_size="750x951"
						# end
					else
						image_size="750x951"
						# change the default values
						# image_info[:publication_date]
						# image_info["image_name"]
					end

					image = Image.create!({ image_name: image_info["image_name"],publication_date: image_info[:publication_date], local_path: image_info[:local_path], media_id: media.id, size: image_size})
					
					images << image

				# otherwise it find the image, and add to the array
				else
					image = Image.find_by_image_name(image_name)
					images << image
				end
			end


			@thread.save

			# add reference to the scraped images to the thread
			@thread.images << images
			@thread.codes << code

			redirect_to "/users/#{current_user.username.split(' ').join('_')}/threads/#{@thread.thread_name}/coding"

		else
			@media = []
			Media.all.each do |newspaper|
				newspaper.name = "#{newspaper.country} - #{newspaper.display_name}"
				@media << newspaper
			end
			if params["topic_name_1"] == ""
				params[:empty_topic] = "true"
			end
			if params[:media] == nil
				params[:empty_media] = "true"
			end
			render "new"
		end

		# render json: params.to_json

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
		# @thread = current_user.owned_threads.find_by_thread_name params[:id]
		# if @thread == nil
		# 	flash[:thread_name_error] = "You don't have premission to edit this thread"
		# 	redirect_to "/threads/"
		# end
		redirect_to "/threads/"
	end

	def update
		@thread = Threadx.find_by_thread_display_name(params[:id])
		@thread.thread_name = params[:threadx]["thread_display_name"].split(' ').join('_')
		@thread.update_attributes!(params[:threadx])
		# @thread.save!
		redirect_to "/users/#{current_user.username}/threads/#{@thread.thread_name}"
	end

	def show
		@thread = Threadx.find_by_thread_name params[:id]
		redirect_to "/users/#{current_user.username}/threads/#{@thread.thread_name}"
	end

	def destroy
		@thread = Threadx.find_by_thread_name params[:id]
		@thread.codes.each do |code|
			code.highlighted_areas.destroy_all
			# destroy the areas also
			code.destroy
		end
		@thread.destroy
		redirect_to "/threads/"
	end

end
