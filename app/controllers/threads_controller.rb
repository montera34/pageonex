require 'odf/spreadsheet'

class ThreadsController < ApplicationController
	# this filter is used to prevent an unregistered user form using the app, except if it was just exploring the threads
	before_filter :authenticate_user!, :except => ["index", "by_username", "search_by_category", "search", "export"]

	# matches the /threads/ url to list all the user owned threads
	# and also matches the /threads/?a=t url to the user owned threads
	def index
		#TODO: this will need pagination soon
		@subtitle = "All Threads"
		@threads = Threadx.page(params[:page])
	end

	def by_username
		@subtitle = "Threads by "+params[:username]
		@user = User.find_by_username params[:username]
		@threads = []
		@threads = @user.owned_threads.page(params[:page]) if @user
		render :index
	end

	def mine
		@subtitle = "Your Threads"
		@threads = current_user.owned_threads.page(params[:page])
		render :index
	end

	def search_by_category
		search_str = params[:q]
		@subtitle = "Threads in the '#{search_str}' category"
		@use_paging = false
		Threadx.per_page = 1000 # don't do paging here
		query = "%#{search_str}%"
		@threads = Threadx.where("(category LIKE ?)", query).all
		render :index
	end

	def search
		search_str = params[:q]
		@subtitle = "Threads about '#{search_str}'"
		@use_paging = false
		Threadx.per_page = 1000 # don't do paging here
		query = "%#{search_str}%"
		@threads = Threadx.joins(:codes).where(
			"(code_text LIKE ?) OR (code_description LIKE ?) OR (thread_display_name LIKE ?) OR (description LIKE ?) OR (category LIKE ?)", 
			query, query, query, query, query
		).all.uniq
		render :index
	end

	# new action render the new form, with the an array of all the media in the db, but before that it do change the name of the media, by formating it, as "#{newspaper.country} - #{newspaper.display_name}" to be sorted by country name in the view
	def new
		@media = Media.by_country_and_display_name.all
		@thread = Threadx.new
		@users = User.hashes
		@usernames = User.pluck(:username)
 		@collaborators = @thread.collaborators.pluck(:username)
	end

	# create action is responsible of processing the submited new form, and create the thread object in the database and handle the validation
	def create
		# create a new threadx object with the submit params related the threadx
		@thread = Threadx.new(params[:threadx])
		
		# set the owner of the thread to the current logged in user
		@thread.owner_id = current_user.id

		# set the thread status with submitted thread status
		@thread.status = params[:status]
		
		# if the thread is opened, sets the last date with today's dates and update the thread each time it's displayed.
		# Now it works only when the Threah is save. Make if work when the thread is opened.
		@thread.end_date = Date.today if @thread.status == "opened"

		# formatting the newspapers_names hash as mentioned above
		@thread.media = Media.where(:id=>params[:media])

		# For any submitted new thread, it should pass the following conditons to be saved to the db
		# (@thread.valid?) this conditions is used to check if the instantiated thread, is passing the validations in the threadx model class
		# (params[:media] != nil) and this condtions to be sure that the thread is submitted with more than one newspaper selected
		# (params["topic_name_1"] != "" ) this condition is to be sure the thread has at least one topic
		if @thread.valid? && params[:media] != nil && params["topic_name_1"] != "" 

			# create object for each code (topic) submited
			codes = [] #creates empty array to store all the codes of the thread
			number_of_codes = params[:topic_count].to_i
			# iterating over the submitted topics, and create a code object for each one. Then add this object to the codes array to assign it to the thread 
			number_of_codes.times do |n|
				code_name = params["topic_name_#{n}"]
				unless code_name.empty?
					codes << Code.create!({:code_text => code_name, 
										   :code_description => params["topic_description_#{n}"],
										   :color => params["topic_color_#{n}"]})
				end
			end

			images = @thread.scrape_all_images

			@thread.collaborators = User.where(:username => params[:collaborators])

			# It saves the thread to the db, and assign an id to the thread
			@thread.save

			# It adds a reference to the scraped images to the thread
			@thread.images << images

			# add the codes to thread
			@thread.codes << codes

			# if all the above goes without any problem, the user will be redirected to the coding action
			redirect_to @thread.link_url + "coding"

		# otherwise, the new form will rendered again with the error messages
		else
			# we should load the names of the media again. 
			@media = Media.by_country_and_display_name.all
			
			# Reload users and collaborators
			@users = User.hashes
			@usernames = User.pluck(:username)
			@collaborators = @thread.collaborators.pluck(:username)

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
		if !current_user.nil? and current_user.admin
			@thread = Threadx.find_by_thread_name params[:id]
		else
			@thread = current_user.owned_threads.find_by_thread_name params[:id]
		end
		# and if the user is not the owner, it redirects the user to the threads index, flash a message to the user to notify him, that he/she doesn't have permission to modify that thread
		if @thread.nil?
			flash[:thread_name_error] = "You don't have premission to edit this thread"
			redirect_to "/threads/"
		else
			@media = Media.by_country_and_display_name.all
			params["media"] = @thread.media.each.collect { |m| m.id }
		end
		@users = User.hashes
		@usernames = User.pluck(:username)
		@collaborators = @thread.collaborators.pluck(:username)
	end


	# the update action is responsible for processing the submitted request, it's pretty much the same as the create action. DRY this!
	def update
		if !current_user.nil? and current_user.admin
			@thread = Threadx.find_by_thread_name params[:id]
		else
			@thread = current_user.owned_threads.find_by_thread_name params[:id]
		end

		@thread.remove_composite_images # make sure to flush the generated composite images (because the update event handler won't catch topic changes)

		@thread.media = Media.where(:id=>params[:media])

		#@thread.codes = params[:codes]
		
		if @thread.update_attributes(params[:threadx])
			
			@thread.status = params[:status]
			@thread.update_attribute(:end_date, Date.today) if @thread.status == "opened"

			images = @thread.scrape_all_images
			
			# Add collaborators
			users = User.where(:username => params[:collaborators]).all
			@thread.collaborators = users
			
			#it should iterate through the recently created codes
			params["code_id"].each_with_index do |id, index|
				code_name = params["topic_name_#{index}"]
				if id.empty?
					unless code_name.empty?
						@thread.codes.create({code_text: code_name, 
							color: params["topic_color_#{index}"], 
							code_description: params["topic_description_#{index}"]})
					end
					# New code
				else
					# Fetch existing code from database by id and update
					code = @thread.codes.find_by_id(id)
					if params["topic_deleted_#{index}"] == '1'
						code.destroy()
					else
						unless code_name.empty?
							code.update_attributes({code_text: code_name, 
								color: params["topic_color_#{index}"], 
								code_description: params["topic_description_#{index}"]})
						end
					end
				end
			end
			@thread.codes.to_enum.with_index.each do |code,index|
				code_name = params["topic_name_#{index}"]
				if params["topic_deleted_#{index}"] == '1'
					code.destroy()
				else #To Do: it should save the new codes created
					unless code_name.empty?
						code.update_attributes({code_text: code_name, 
							color: params["topic_color_#{index}"], 
							code_description: params["topic_description_#{index}"]})
					end
				end
			end

			@thread.save	

			# if the user did not select the option for keeping the highlighted areas of the removed images, they will be deleted
			thread_image_ids = @thread.images.collect { |img| img.id }
			if params["clean_high_areas"] != "1"
				@thread.highlighted_areas.each do |ha|
					ha.destroy unless thread_image_ids.include? ha.image_id
				end
			end

			# and then redirect the user to the display view
			redirect_to @thread.link_url
		else
			# A method should be created to make a DRY code. don't repeat!
			@media = Media.by_country_and_display_name.all

			@thread.media.each do |m|
				params["media"] << "#{m.id}"
			end
		
			render "edit"	
		end

	end

	# the show action, is for displaying a thread
	def show
		@thread = Threadx.find_by_thread_name params[:id]
		redirect_to @thread.link_url
	end

	# the destroy actions, is for deleting a thread
	def destroy
		@thread = Threadx.find_by_thread_name params[:id]
		@thread.codes.destroy_all
		@thread.highlighted_areas.destroy_all
		@thread.destroy
		redirect_to "/threads/"
	end

	def new_topic #we should be consitent and use code or topic
		render :partial => 'topic_form', :locals => {
			:index => params[:index], :id => nil, :name => nil, :color => nil, :description => nil}
	end
	
	def export
		@thread = Threadx.find_by_thread_name params[:thread_name]
		respond_to do |format|
			format.html
			format.json { render :json => @thread.results.to_json }
			format.ods do
				send_file results_to_ods(@thread.results),
					:filename => 'export.ods',
					:type => 'application/x-vnd.oasis.opendocument.spreadsheet',
					:disposition => 'attachment'
			end
			format.svg do
				send_file '<svg><rect width="1" height="1"></svg>',
					:filename => 'export.svg',
					:type => 'image/svg+xml',
					:disposition => 'attachment'
			end
			format.jpeg do
				width = Threadx::DEFAULT_COMPOSITE_IMAGE_WIDTH
				width = params['width'].to_i if params['width']
				@thread.generate_composite_images width
				if params['image_export_type']=='jpg'
					send_file File.join(@thread.composite_img_dir(width),'results.jpg'), :type=>'image/jpg', :disposition=>'inline'
				else
					send_file File.join(@thread.composite_img_dir(width),'results.zip'), 
						:type=>'application/x-zip-compressed ', 
						:disposition=>'attachment'					
				end
			end
		end
	end

	def results_to_ods(results)
		spreadsheet = ODF::Spreadsheet.new
		# Create tables and headers
		tables = {}
		results[:media].each do |m|
			tables[m] = spreadsheet.table m
			row = tables[m].row
			row.cell 'Date', :type=>:string
			results[:codes].each do |c|
				row.cell c, :type=>:string
			end
		end
		# We use the arrays rather than hash keys to guarantee ordering
		results[:dates].each do |date|
			results[:media].each do |m|
				row = tables[m].row
				row.cell date, :type=>:date
				results[:codes].each do |code|
					code_percent = results[:data][date][m]
					if not code_percent.nil?
						row.cell code_percent[code], :type=>:float
					end
				end
			end
		end
		# Create a temporary filepath
		file = Tempfile.new(['export', '.ods']);
		path = file.path
		file.close
		file.unlink
		spreadsheet.write_to(path)
		return path
	end
end
