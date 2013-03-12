class ThreadsController < ApplicationController
	# this filter is used to prevent an unregistered user form using the app, except if it was just exploring the threads
	before_filter :authenticate_user!, :except => "index"

	# matches the /threads/ url to list all the user owned threads
	# and also matches the /threads/?a=t url to the user owned threads
	def index
	end

	# new action render the new form, with the an array of all the media in the db, but before that it do change the name of the media, by formating it, as "#{newspaper.country} - #{newspaper.display_name}" to be sorted by country name in the view
	def new
		@media = Media.all
		@thread = Threadx.new
	end

	# create action is responsible of processing the submited new form, and create the thread object in the database and handle the validation
	def create
		# create a new threadx object with the submit params related the threadx
		@thread = Threadx.new(params[:threadx])
		
		# format the thread name, by replace spaces with underscores
		@thread.thread_name = Threadx.url_safe_name @thread.thread_display_name
		
		# set the owner of the thread to the current logged in user
		@thread.owner_id = current_user.id

		# set the thread status with submitted thread status
		@thread.status = params[:status]
		
		# if the thread is opened, sets the last date with today's dates and update the thread each time it's displayed.
		# Now it works only when the Threah is save. Make if work when the thread is opened.
		if @thread.status == "opened"
			@thread.end_date = Date.today
		end

		# the value of the media will be an array of the media ids, like [23,522,12,4]
		media = params[:media]

		# formatting the newspapers_names hash as mentioned above
		media.each do |m|
			_media = Media.find(m)
			@thread.media << _media
		end
		# this array is made to be passed to Scraper.get_issues method, because this method accepts the specific format of newspapers names as the following
		# {"es" => ["elpais", "abc"], "de" => ["faz", "bild"], "fr" => ["lemonde", "lacroix"], "it" => ["corriere_della_sera", "ilmessaggero"], "uk" => ["the_times", ],"us" => ["wsj", "newyork_times", "usa_today"]}
		# name attribute holds the name of the newspaper {"elpais", "abc", ...}
		newspapers_names = Media.get_names_from_list @thread.media

				 
		# For any submitted new thread, it should pass the following conditons to be saved to the db
		# (@thread.valid?) this conditions is used to check if the instantiated thread, is passing the validations in the threadx model class
		# (params[:media] != nil) and this condtions to be sure that the thread is submitted with more than one newspaper selected
		# (params["topic_name_1"] != "" ) this condition is to be sure the thread has at least one topic
		if @thread.valid? && params[:media] != nil && params["topic_name_1"] != "" 
			
			# this array is made to be passed to Scraper.get_issues method, because this method accepts the specific format of newspapers names as the following
			# {"es" => ["elpais", "abc"], "de" => ["faz", "bild"], "fr" => ["lemonde", "lacroix"], "it" => ["corriere_della_sera", "ilmessaggero"], "uk" => ["the_times", ],"us" => ["wsj", "newyork_times", "usa_today"]}
			# name attribute holds the name of the newspaper {"elpais", "abc", ...}
			newspapers_names = {}

			# the value of the media will be an array of the media ids, like [23,522,12,4]
			media = params[:media]

			# formatting the newspapers_names hash as mentioned above
			media.each do |m|
				_media = Media.find(m)
				@thread.media << _media
				# for each media country_code(code like  {"es", "de", ...}) it appends the newspapers
				if newspapers_names[_media.country_code] != nil
					newspapers_names[_media.country_code] << _media.name 
				# but if the country_code array is empty, it will create a new array
				else
					newspapers_names[_media.country_code] = []
					newspapers_names[_media.country_code] << _media.name
				end
			end

			# create object for each code (topic) submited
			codes = []
			number_of_topics = params[:topic_count].to_i
			# iterating over the submitted topics, and create a code object for each one. Then add this object to the codes array to assign it to the thread 
			number_of_topics.times do |n|
				codes << Code.create!({:code_text => params["topic_name_#{n}"], :code_description => params["topic_description_#{n}"],:color => params["topic_color_#{n}"]})
			end

			# array of object refers to scraped images
			images = []

			# passes dates and formated newspapers_names array. It returns a hash that contains info about evry image: publication_date, media, local_path 
			# in the future, if we want to add the feature for choosing between multiple scraper, it will be here, by passing another argument to the scraper to choose the source for scraping
			newspapers_images = Scraper.get_issues(@thread.start_date, @thread.end_date, newspapers_names)

			# after the scraper finishes, it returns a hash of the scraped images
			# this returned hash contains the image names which are in this format [newspaper_name-publication_date], the url, and the media id
			newspapers_images.each do |image_name, image_info|
				# search if the image dose not exist, it creates an object for this image 
				if ( (image = Image.find_by_image_name image_name) == nil)
					image_info["image_name"] = image_name
					media = Media.find_by_name(image_info[:media])

					# I'll change this part, for the deployment on the server
					if image_info[:local_path] != "404.jpg"
						# image_size = Magick::ImageList.new("app/assets/images" + image_info[:local_path])[0]
						# image_size = "#{image_size.columns}x#{image_size.rows}"

						# for the online heroku beta
							image_size="750x951" #!!this value of pixels is 'hard coded' so it gives wrong values for long newspapers
						# end
					else
						image_size="750x951" #!!this value of pixels is 'hard coded' so it gives wrong values for long newspapers
						# this part is comment for heroku beta
						# change the default values
						# image_info[:publication_date]
						# image_info["image_name"]
					end

					# creates a new image object if there is no exsiting image object for the scraped image, because the image objects is global for all the threads
					# we are storing the image url in the local_path attribute for the heroku deployment, but for the future deployment on the server, we will store the path of the image on the server in the local_path and the url in the a url attribute
					image = Image.create!({ image_name: image_info["image_name"],publication_date: image_info[:publication_date], local_path: image_info[:local_path], media_id: media.id, size: image_size})
				end
			end

			# It saves the thread to the db, and assign an id to the thread
			@thread.save

			# It adds a reference to the scraped images to the thread
			@thread.images << images

			# add the codes to thread
			@thread.codes << codes

			# if all the above goes without any problem, the user will be redirected to the coding action
			redirect_to "/#{current_user.username.split(' ').join('_')}/#{@thread.thread_name}/coding"

		# otherwise, the new form will rendered again with the error messages
		else
			# we should load the names of the media again. 
			# A method should be created to make a DRY code. don't repeat!
			@media = []
			Media.all.each do |newspaper|
				newspaper.name = "#{newspaper.country} - #{newspaper.display_name}"
				@media << newspaper
			end

			# send some params back to the view, to tell the user about what is missing
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
		# and if the user is not the owner, it redirects the user to the threads index, flash a message to the user to notify him, that he/she doesn't have permission to modify that thread
		if @thread == nil
			flash[:thread_name_error] = "You don't have premission to edit this thread"
			redirect_to "/threads/"
		end

		@media = Media.all

		params["media"] = []
		@thread.media.each do |m|
			params["media"] << m.id
		end
	
	end


	# the update action is responsible for processing the submitted request, it's pretty much the same as the create action. DRY this!
	def update
		@thread = current_user.owned_threads.find_by_thread_name params[:id]
		# don't change the thread_name property (ie. the url) even if the display name changes
		media = params[:media]

		@thread.media = []
		media.each do |m|
			_media = Media.find(m)
			@thread.media << _media
		end
		newspapers_names = Media.get_names_from_list @thread.media
		
		if @thread.update_attributes(params[:threadx])
			
			@thread.status = params[:status]
			if @thread.status == "opened"
				@thread.update_attribute(:end_date, Date.today)
			end

			if true
				newspapers_names = {}
				@thread.media = []

				media.each do |m|
					_media = Media.find(m)
					@thread.media << _media
					if newspapers_names[_media.country_code] != nil
						newspapers_names[_media.country_code] << _media.name 
					else
						newspapers_names[_media.country_code] = []
						newspapers_names[_media.country_code] << _media.name
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
							image_size="750x951" #!!this value of pixels is 'hard coded' so it gives wrong values for long newspapers
							# end
						else
							image_size="750x951" #!!this value of pixels is 'hard coded' so it gives wrong values for long newspapers
							# change the default values
							# image_info[:publication_date]
							# image_info["image_name"]
						end

						image = Image.create!({ image_name: image_info["image_name"],publication_date: image_info[:publication_date], local_path: image_info[:local_path], media_id: media.id, size: image_size})
					end
				end
			end
			if true
				@thread.codes.to_enum.with_index.each do |code,index|
					if params["topic_deleted_#{index}"] == '1'
						code.destroy()
					else
						code.update_attributes({code_text: params["topic_name_#{index}"], color: params["topic_color_#{index}"], code_description: params["topic_description_#{index}"]})
					end
				end
			end

			@thread.save	

			# if the user did not select the option for keeping the highlighted areas of the removed images, so they will be deleted
			if params["clean_high_areas"] != "1"
				@thread.highlighted_areas.each do |ha|
					ha.destroy unless @thread.images.include? ha.image
				end
			end

			# and then redirect the user to the display view
			redirect_to "/#{current_user.username.split(' ').join('_')}/#{@thread.thread_name}"
		else
			# A method should be created to make a DRY code. don't repeat!
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

		# 
=begin
	
for opened thread:
	each time a user opens the thread, check first if the status is opened, if so:
		- check if the end date is the same as today, if not change the date
		- and also checks if the thread length exceeds 90 days, if so it will not update the thread
		- and run the scraper again to update the thread

=end		

		redirect_to "/#{current_user.username.split(' ').join('_')}/#{@thread.thread_name}"
	end

	# the destroy actions, is for deleting a thread
	def destroy
		@thread = Threadx.find_by_thread_name params[:id]
		@thread.codes.destroy_all
		@thread.highlighted_areas.destroy_all
		@thread.destroy
		redirect_to "/threads/"
	end

	def new_topic
		render :partial => 'topic_form', :locals => {
			:index => params[:index], :name => nil, :color => nil, :description => nil}
	end

end
