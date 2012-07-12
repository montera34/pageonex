class CodingController < ApplicationController
	before_filter :authenticate_user!

	def process_images
		@thread = Threadx.find_by_thread_name params[:thread_name]		
		@images = @thread.images
		@image_counter = @thread.images.length
		@highlighted_areas = []
		
		@thread.codes.each do |code|
			code.highlighted_areas.each do |high_area|
				@highlighted_areas << high_area
			end
		end
		
		# render json: @highlighted_areas.to_json
	end

	def display
		@thread = Threadx.find_by_thread_name params[:thread_name]	
		@images = @thread.images
		@image_counter = @thread.images.length
		@image_counter.downto(1) do |c|
				2.downto(1) do |hc|
					if params["image#{c}_ha#{hc}"] == "1"
						
						highlighted_area = HighlightedArea.create!({:image => @images[c-1], user: current_user, code_id: params["image#{c}_ha#{hc}_code_id"].to_i})

						Area.create!({x1: params["image#{c}_ha#{hc}_x1"].to_i, y1: params["image#{c}_ha#{hc}_y1"].to_i, x2: params["image#{c}_ha#{hc}_x2"].to_i, y2: params["image#{c}_ha#{hc}_y2"].to_i, width: params["image#{c}_ha#{hc}_width"].to_i, height: params["image#{c}_ha#{hc}_height"].to_i, highlighted_area: highlighted_area})
					end
				end	
		end

		@highlighted_areas = []
		@thread.codes.each do |code|
			code.highlighted_areas.each do |high_area|
				@highlighted_areas << high_area
			end
		end

		# render json: params.to_json
	end
end
