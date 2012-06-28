class ThreadsController < ApplicationController
	before_filter :authenticate_user!, :except => :show

	def index
		
	end

	def create
		@thread = Threadx.new
		@thread.update_attributes!(params[:threadx])
		redirect_to "/"
	end

	def new
		@media = []
		@thread = Threadx.new
		Media.all.each do |newspaper|
			newspaper.name = "#{newspaper.display_name} - #{newspaper.country}"
			@media << newspaper
		end

	end

	def edit
		
	end

	def update
		
	end

	def show
		render :text => params[:id]
	end

end
