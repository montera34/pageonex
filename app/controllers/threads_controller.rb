class ThreadsController < ApplicationController
	before_filter :authenticate_user!, :except => :show

	def index
		
	end

	def create
		#render :json => params.to_json
		@thread = Threadx.new
		@thread.update_attributes!(params[:threadx])
		redirect_to "/"
	end

	def new
		@thread = Threadx.new
		@media = Media.all
	end

	def edit
		
	end

	def update
		
	end

	def show
		render :text => params[:id]
	end

end
