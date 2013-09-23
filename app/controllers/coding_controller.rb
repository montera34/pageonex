class CodingController < ApplicationController
  before_filter :authenticate_user!, :except => [:display, :process_images]

  # render the coding view
  def process_images
    @thread = Threadx.find_by_thread_name params[:thread_name]
    @highlighted_areas = @thread.highlighted_areas
    @allowed_to_code = @thread.allowed_to_code? current_user
    @images = @thread.images_by_date  # while coding we want to go day by day, NOT media by media
  end

  # process the submitted highlighted area from the coding view, and redirect to the display
  def process_highlighted_areas
    @thread = Threadx.find_by_thread_name params[:thread_name]

    @thread.remove_composite_images # flush the generated composite images because there is a new highlighted area

    @images = @thread.images

    # Look for images with nothing to code
    params[:image_name].each do |image_name|
      image = Image.find_by_id(image_name)
      @thread.coded_pages.for_user(current_user).for_image(image).delete_all
      if params["nothing_to_code_#{image_name}"] == '1'
	     @thread.coded_pages.create(:user_id => current_user.id, :image_id => image.id)
      end
    end
    # Go through each submitted highlighted area
    params.fetch(:ha_name, []).each do |ha_name|
      image = Image.find_by_id(params["img_id_#{ha_name}"])
      
      if params["id_#{ha_name}"].to_i == 0
      	# This is a new area, create it if it hasn't been deleted
      	next if params["deleted_#{ha_name}"].to_i == 1
      	code = Code.find params["code_id_#{ha_name}"]
      	ha = code.highlighted_areas.create(:image_id=>image.id, :code_id=>code.id, :user_id=>current_user.id)
      	area = Area.create(highlighted_area_id: ha.id, x1: params["x1_#{ha_name}"].to_i, 
          y1: params["y1_#{ha_name}"].to_i, x2: params["x2_#{ha_name}"].to_i, 
          y2: params["y2_#{ha_name}"].to_i, width: params["width_#{ha_name}"].to_i, 
          height: params["height_#{ha_name}"].to_i)
      else
      	# Updating an existing area
      	ha = @thread.highlighted_areas.find(params["id_#{ha_name}"])
      	if params["deleted_#{ha_name}"] == '1'
      	  ha.areas.each do |a|
      	    a.destroy
      	  end
      	  ha.destroy
      	else
      	  ha.update_attribute('code_id', params["code_id_#{ha_name}"].to_i)
      	  ha.areas[0].update_attributes(x1: params["x1_#{ha_name}"].to_i, 
            y1: params["y1_#{ha_name}"].to_i, x2: params["x2_#{ha_name}"].to_i, 
            y2: params["y2_#{ha_name}"].to_i, width: params["width_#{ha_name}"].to_i, 
            height: params["height_#{ha_name}"].to_i)
      	end
      end
    end
    @image_counter = @thread.images.length

    # set the highlighted areas values
    @thread.highlighted_areas.each do |ha|
      # if the status of highlighted areas is "1" it means this highlighted areas have changed
      if params["#{ha.name}_status"] == "1"
        # if the highlighted areas is "0" thats mean this highlighted areas have changed is cleared
        if params["#{ha.name}"] == "0"
          ha.update_attribute("code_id",0)          
          ha.areas[0].update_attributes({x1:0, y1:0, x2:0, y2:0 , width:0, height:0})
        else
          code_id = params["#{ha.name}_code_id"]
          ha.update_attribute("code_id",code_id.to_i)
          ha.areas[0].update_attributes({x1: params["#{ha.name}_x1"].to_i, y1: params["#{ha.name}_y1"].to_i, x2: params["#{ha.name}_x2"].to_i, y2: params["#{ha.name}_y2"].to_i, width: params["#{ha.name}_width"].to_i, height: params["#{ha.name}_height"].to_i})
        end
      end

    end

    # if the user clicked "Save" button, so it will redirect the user to the coding view again, otherwise it will redirect to the coding
    if params[:commit] == "Save"
      redirect_to :back
    else
      redirect_to @thread.link_url
    end
  end

  # render display view
  def display
    @thread = Threadx.find_by_thread_name params[:thread_name]
    if @thread.nil?
      raise ActionController::RoutingError.new('Not Found')
    else
      # prep the composite image to show
      @thread.generate_composite_images # make sure composite results images have been generated
      @img_map_info = @thread.composite_image_map_info
      #prep to show collaborators of a thread
      @users = User.hashes
      @usernames = User.pluck(:username)
      @collaborators = @thread.collaborators.pluck(:username)
    end
  end

end
