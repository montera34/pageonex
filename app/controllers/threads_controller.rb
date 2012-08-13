class ThreadsController < ApplicationController
	before_filter :authenticate_user!

	def index
		@threads = current_user.owned_threads
	end

	def create

		@thread = Threadx.new(params[:threadx])
		@thread.thread_name = params[:threadx]["thread_display_name"].split(' ').join('_').downcase
		@thread.owner_id = current_user.id
		@thread.status = params[:status]
		# if the thread is opened, set the last date with today date and update the thread each time it displayed
		if @thread.status == "opened"
			@thread.end_date = Date.today
		end
				 
		if @thread.valid? && params[:media] != nil && params["topic_name_1"] != "" 

			
			# this array is made to passed to Scraper.get_issues method, because this method accept the specific format of newspapers names as the following
			# {"es" => ["elpais", "abc"], "de" => ["faz", "bild"], "fr" => ["lemonde", "lacroix"], "it" => ["corriere_della_sera", "ilmessaggero"], "uk" => ["the_times", ],"us" => ["wsj", "newyork_times", "usa_today"]}
			# city attribute holds the country code like {"es", "de", ...}
			# name attribute holds the name of the newspaper {"elpais", "abc", ...}
			newspapers_names = {}

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
			newspapers_images = Scraper.get_issues(@thread.start_date, @thread.end_date, newspapers_names)

			newspapers_images.each do |image_name, image_info|
				# search if the image dose not exsit, it create an object for this image 
				if ( (image = Image.find_by_image_name image_name) == nil)
					image_info["image_name"] = image_name
					media = Media.find_by_name(image_info[:media])

					if image_info[:local_path] != "404.jpg"
						# image_size = Magick::ImageList.new("app/assets/images" + image_info[:local_path])[0]
						# image_size = "#{image_size.columns}x#{image_size.rows}"

						# for the online heroku beta
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

			@thread.images.each do |img|
				highlighted_area1 = HighlightedArea.create!({:name => "image#{img.id}_ha1" ,:image => img, user: current_user,  threadx: @thread })

				Area.create({highlighted_area: highlighted_area1})

				highlighted_area2 = HighlightedArea.create!({:name => "image#{img.id}_ha2" ,:image => img, user: current_user,threadx: @thread })

          		Area.create({highlighted_area: highlighted_area2})
			end

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
		@thread = current_user.owned_threads.find_by_thread_name params[:id]
		if @thread == nil
			flash[:thread_name_error] = "You don't have premission to edit this thread"
			redirect_to "/threads/"
		end
		@media = []
		Media.all.each do |newspaper|
			newspaper.name = "#{newspaper.country} - #{newspaper.display_name}"
			@media << newspaper
		end

		params["media"] = []
		@thread.media.each do |m|
			params["media"] << m.id
		end
	

		# render json: params["media"].to_json
	end

	def update
		@thread = current_user.owned_threads.find_by_thread_name params[:id]
		@thread.thread_name = params[:threadx]["thread_display_name"].split(' ').join('_').downcase
		media = params[:media]


		if @thread.update_attributes(params[:threadx])
			
			@thread.status = params[:status]
			if @thread.status == "opened"
				@thread.update_attribute(:end_date, Date.today)
			end

			if true
				images = []
				newspapers_names = {}
				@thread.media = []

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
				
				newspapers_images = Scraper.get_issues(@thread.start_date, @thread.end_date, newspapers_names)

				newspapers_images.each do |image_name, image_info|
					# search if the image dose not exsit, it create an object for this image 
					if ( (image = Image.find_by_image_name image_name) == nil)
						image_info["image_name"] = image_name
						media = Media.find_by_name(image_info[:media])

						if image_info[:local_path] != "404.jpg"
							# image_size = Magick::ImageList.new("app/assets/images" + image_info[:local_path])[0]
							# image_size = "#{image_size.columns}x#{image_size.rows}"

							# for the online heroku beta
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
				
				@thread.images = []
				@thread.images << images
			end
			if true
				@thread.codes[0].update_attributes({code_text: params[:topic_name_1], color: params[:topic_color_1], code_description: params[:topic_description_1]})
			end

			@thread.save	

			# delete unused highlighed areas
			if params["clean_high_areas"] != "1"
				@thread.highlighted_areas.each do |ha|
					ha.destroy unless @thread.images.include? ha.image
				end
			end

			@thread.images.each do |img|
				if img.highlighted_areas.find_by_threadx_id(@thread.id) == nil
					highlighted_area1 = HighlightedArea.create!({:name => "image#{img.id}_ha1" ,:image => img, user: current_user,  threadx: @thread })

					Area.create({highlighted_area: highlighted_area1})

					highlighted_area2 = HighlightedArea.create!({:name => "image#{img.id}_ha2" ,:image => img, user: current_user,threadx: @thread })

	          		Area.create({highlighted_area: highlighted_area2})
	          	end
			end

			redirect_to "/users/#{current_user.username.split(' ').join('_')}/threads/#{@thread.thread_name}"
			# render json: params.to_json
		else

			@media = []
			Media.all.each do |newspaper|
				newspaper.name = "#{newspaper.country} - #{newspaper.display_name}"
				@media << newspaper
			end

			@thread.media.each do |m|
				params["media"] << "#{m.id}"
			end

			

			render "edit"	
			# render json: params.to_json
		end
		
		# render json: params.to_json	

	end

	def show
		@thread = Threadx.find_by_thread_name params[:id]
=begin
	
for opened thread:
	each time a user open the thread, check first if the status is opened, if so:
		- check if the end date is the same as today, if not change the date
		- and run the scraper again to update the thread

=end		

		redirect_to "/users/#{current_user.username.split(' ').join('_')}/threads/#{@thread.thread_name}"
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
