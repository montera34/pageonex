class ThreadsController < ApplicationController
	# this filter is used to prevent an unregistered user form using the app, except if it was just exploring the threads
	before_filter :authenticate_user!, :except => "index"

	# matches the /threads/ url to list all the user owned threads
	# and also matches the /threads/?a=t url to the user owned threads
	def index
	end

	# new action render the new form, with the an array of all the media in the db, but before that it do change the name of the media, by formating it, as "#{newspaper.country} - #{newspaper.display_name}" to be sorted by country name in the view
	def new
		@media = []
		@thread = Threadx.new
		Media.all.each do |newspaper|
			# for each media object it changes its name on fly(with actually effecting the object in the db) and it to the @media array
			newspaper.name = "#{newspaper.country} - #{newspaper.display_name}"
			@media << newspaper
		end
		
	end

	# create action is responsible of processing the submited new form, and create the thread object in the database and handel the validation
	def create
		# create a new threadx object with the submit params related the threadx
		@thread = Threadx.new(params[:threadx])
		
		# format the thread name, by replace spaces with underscores
		@thread.thread_name = params[:threadx]["thread_display_name"].split(' ').join('_').downcase
		
		# set the owner of the thread to the current logged in user
		@thread.owner_id = current_user.id

		# set the thread status with submitted thread
		@thread.status = params[:status]
		
		# if the thread is opened, set the last date with today date and update the thread each time it displayed
		if @thread.status == "opened"
			@thread.end_date = Date.today
		end
				 
		# any submitted new thread, it should pass the following conditons to be saved to the db
		# (@thread.valid?) this conditions is used to check if the instantiated thread, is passing the validations in the threadx model class
		# (params[:media] != nil) and this condtions to be sure that the thread is submitted with a more than newspaper selected
		# (params["topic_name_1"] != "" ) this condition is to be sure the thread at least submitted with on topic
		if @thread.valid? && params[:media] != nil && params["topic_name_1"] != "" 
			
			# this array is made to passed to Scraper.get_issues method, because this method accept the specific format of newspapers names as the following
			# {"es" => ["elpais", "abc"], "de" => ["faz", "bild"], "fr" => ["lemonde", "lacroix"], "it" => ["corriere_della_sera", "ilmessaggero"], "uk" => ["the_times", ],"us" => ["wsj", "newyork_times", "usa_today"]}
			# city attribute holds the country code which is the second column in the kisoko.csv file, and the city attribute should be changed to country_code instead like {"es", "de", ...} 
			# name attribute holds the name of the newspaper {"elpais", "abc", ...}
			newspapers_names = {}

			# the value of the media will be an array of the media ids, like [23,522,12,4]
			media = params[:media]

			# formating the newspapers_names hash as mentioned above
			media.each do |m|
				_media = Media.find(m)
				@thread.media << _media
				# for each media city(code like  {"es", "de", ...}) it dose append the newspapers
				if newspapers_names[_media.city] != nil
					newspapers_names[_media.city] << _media.name 
				# but if the city is array is empty, it will create a new array
				else
					newspapers_names[_media.city] = []
					newspapers_names[_media.city] << _media.name
				end
			end

			# create object for each code submited
			codes = []
			number_of_topics = params[:topic_count].to_i
			# iterating over the submitted topics, and create a code object for each on and add this object to the codes array to assign it the thread 
			1.upto(number_of_topics) do |n|
				codes << Code.create!({:code_text => params["topic_name_#{n}"], :code_description => params["topic_description_#{n}"],:color => params["topic_color_#{n}"]})
			end

			# array of object refers to scraped images
			images = []

			# passes dates and formated newspapers_names array, and the return is a hash contains info about each images(publication_date, media, local_path)
			# in the future, if we want to add the feature for choosing between multiple scraper, so it will be here, by passing another argument to the scraper to choose the source for scraping
			newspapers_images = Scraper.get_issues(@thread.start_date, @thread.end_date, newspapers_names)

			# after the scraper finishes, it return hash of the scraped images
			# this returned hash contains the images name which is in this format [newspaper_name-publication_date], the url, and the media id
			newspapers_images.each do |image_name, image_info|
				# search if the image dose not exsit, it create an object for this image 
				if ( (image = Image.find_by_image_name image_name) == nil)
					image_info["image_name"] = image_name
					media = Media.find_by_name(image_info[:media])

					# I'll change this part, for the deployment on the server
					if image_info[:local_path] != "404.jpg"
						# image_size = Magick::ImageList.new("app/assets/images" + image_info[:local_path])[0]
						# image_size = "#{image_size.columns}x#{image_size.rows}"

						# for the online heroku beta
							image_size="750x951"
						# end
					else
						image_size="750x951"
						# this part is comment for heroku beta
						# change the default values
						# image_info[:publication_date]
						# image_info["image_name"]
					end

					# create a new image object if there is was no exsiting image object for the scraped image, because image objects is global for all the threads
					# we are storing the image url in the local_path attribute for the heroku deployment, but for the future deployment on the server, we will store the path of the image on the server in the local_path and the url in the a url attribute
					image = Image.create!({ image_name: image_info["image_name"],publication_date: image_info[:publication_date], local_path: image_info[:local_path], media_id: media.id, size: image_size})
					
					images << image

				# otherwise it finds the image, and add it to the images array
				else
					image = Image.find_by_image_name(image_name)
					images << image
				end
			end

			# save the thread to the db, and assign an id to the thread
			@thread.save

			# add reference to the scraped images to the thread
			@thread.images << images

			# add the highlighted areas, the thread
			# there is a limitation in this version which is; it supports two highlighted areas for each image
			# we can in the future add loop to add any number of highlighted areas
			@thread.images.each do |img|

				highlighted_area1 = HighlightedArea.create!({:name => "image#{img.id}_ha1" ,:image => img, user: current_user, threadx: @thread })
				Area.create({highlighted_area: highlighted_area1})

				highlighted_area2 = HighlightedArea.create!({:name => "image#{img.id}_ha2" ,:image => img, user: current_user,threadx: @thread })
    		Area.create({highlighted_area: highlighted_area2})

			end

			# add the codes to thread
			@thread.codes << codes

			# if all the above goes without any problem, the user will be redirected to the coding action
			redirect_to "/users/#{current_user.username.split(' ').join('_')}/threads/#{@thread.thread_name}/coding"

		# otherwise, the new form will rendered again with the error messages
		else
			# we should load the names of the media again
			@media = []
			Media.all.each do |newspaper|
				newspaper.name = "#{newspaper.country} - #{newspaper.display_name}"
				@media << newspaper
			end

			# send some params back to the view, to till the user about what is missing
			if params["topic_name_1"] == ""
				params[:empty_topic] = "true"
			end
			if params[:media] == nil
				params[:empty_media] = "true"
			end

			# and then render the new form again
			render "new"
		end

	end


	# edit action is responsible for rendering the edit thread form
	def edit
		# set the @thread object with the thread from the user owned threads
		@thread = current_user.owned_threads.find_by_thread_name params[:id]
		# and if the user wasn't the owner, it redirect the user to the threads index, flash a message to the user to notify him, that he/she don't have a premission to modify this thread
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
	
	end


	# the update action is responsible for the processing the submitted request, it's pretty much the same as the create action
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
				@thread.codes.to_enum.with_index.each do |code,index|
					code.update_attributes({code_text: params["topic_name_#{index+1}"], color: params["topic_color_#{index+1}"], code_description: params["topic_description_#{index}"]})
				end
			end

			@thread.save	

			# if the user did not select the option for keeping the highlighted areas of the removed images, so they will be deleted
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

			# and then redirect the user to the display view
			redirect_to "/users/#{current_user.username.split(' ').join('_')}/threads/#{@thread.thread_name}"
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
		end

	end


	# the show action, is for displaying a thread
	def show
		@thread = Threadx.find_by_thread_name params[:id]

		# I think I've forget to finish this part, so I'll do it first thing tomorrw after the meeting!
=begin
	
for opened thread:
	each time a user open the thread, check first if the status is opened, if so:
		- check if the end date is the same as today, if not change the date
		- and also checks if the thread length exceeds 90 days, if so it will not update the thread
		- and run the scraper again to update the thread

=end		

		redirect_to "/users/#{current_user.username.split(' ').join('_')}/threads/#{@thread.thread_name}"
	end

	# the destroy actions, is for deleting threads 
	def destroy
		@thread = Threadx.find_by_thread_name params[:id]
		@thread.codes.each do |code|
			code.highlighted_areas.destroy_all
			code.destroy
		end
		@thread.destroy
		redirect_to "/threads/"
	end

end
