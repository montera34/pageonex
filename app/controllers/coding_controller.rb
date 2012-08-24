class CodingController < ApplicationController
  before_filter :authenticate_user!, :except => :display

  # render the coding view
  def process_images
    # set the @thread variable with the request thread
    @thread = Threadx.find_by_thread_name params[:thread_name]
    @image_counter = @thread.images.length
    @highlighted_areas = []

    # add only the hightlighted area related to existing images
    @thread.highlighted_areas.each do |ha|
      @highlighted_areas << ha if @thread.images.include? ha.image
    end

    
=begin

There is a problem in sorting; which is the images is scraped and sorted by the media name, and then we sort them by their publication date, but there is the get sorted a weird order in the carrousel for example:

  It should make it: 
  Date n: newspapers a b c d. 
  Date n+1: newspapers a b c d.

  Now it is making:
  Date n: newspapers a b c d. 
  Date n+1: newspapers d c b a. 

So the following sorting method should be modified
=end
    # sort the images by their publication_date
    @images = @thread.images.sort do |img1, img2|
      img1.publication_date <=> img2.publication_date
    end 

  end

  # process the submitted highlighted area from the coding view, and redirect to the display
  def process_highlighted_areas
    @thread = Threadx.find_by_thread_name params[:thread_name]
    # sort the images
    @images = @thread.images.sort do |img1, img2|
      img1.publication_date <=> img2.publication_date
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
      redirect_to :back #"/users/#{current_user.username.split(' ').join('_')}/threads/#{@thread.thread_name}/coding/"
    else
      redirect_to "/users/#{current_user.username.split(' ').join('_')}/threads/#{@thread.thread_name}"
    end
  end

  # render display view
  def display
    @thread = Threadx.find_by_thread_name params[:thread_name]
    
    # sort images by their publication date
    @images = @thread.images.sort do |img1, img2|
      img1.publication_date <=> img2.publication_date
    end
    
    @image_counter = @thread.images.length
    @codes = @thread.codes
    

    @highlighted_areas = []
    # add only the hightlighted area related to existing images
    @thread.highlighted_areas.each do |ha|
      @highlighted_areas << ha if @thread.images.include? ha.image
    end
    
    # sort highlighted areas by the image name
    @highlighted_areas.sort! do |ha1,ha2|
    	ha1.name.split('_')[0][5..100].to_i <=> ha2.name.split('_')[0][5..100].to_i
    end


    # This part is used to calculate the highlighted areas percentages vertically 
    @images_columns = {}

    @high_areas_per = {}
    
    @codes_high_areas = {}

    @ratios = {}

    images_per_row = @thread.images.length / @thread.media.length

    1.upto(images_per_row) do |c|
    	@images_columns["c#{c}"] = []
    end

    1.upto(images_per_row) do |c|
      @high_areas_per["c#{c}"] = []
    end

    1.upto(images_per_row) do |c|
      @ratios["#{c}"] = 0
    end

    1.upto(images_per_row) do |c|
      @codes_high_areas["c#{c}"] = {}
      @codes.each do |code|
        @codes_high_areas["c#{c}"]["code_#{code.id}"] = 0.0
      end
      
    end

    @sorted_images = @thread.images.sort do |img1, img2|
      img1.publication_date <=> img2.publication_date
    end

    cr = 1
    d = @sorted_images.first.publication_date.day
    @sorted_images.each do |img|
      if img.publication_date.day == d
        @images_columns["c#{cr}"] << img
      else
        d = img.publication_date.day
        cr += 1
        @images_columns["c#{cr}"] << img
      end
    end
    @images_columns.each do |cr,imgs|
      imgs.each do |img|
        img.highlighted_areas.each do |ha|
          if @codes.include? ha.code
            highlighted_area = ha.areas[0]["height"].to_f * ha.areas[0]["width"].to_f
            image_area = ha.image.size.split("x")[0].to_f * ha.image.size.split("x")[1].to_f
            ratio = (highlighted_area / image_area) * 100
            @codes_high_areas[cr]["code_#{ha.code.id}"] += ratio.ceil
         end
        end 
      end 
    end 

    number_of_rows = @thread.media.length
    @codes_high_areas.each do |column,codes|
      codes.each do |code_id, value|
        @codes_high_areas[column][code_id] = value/number_of_rows
      end
    end

  end
end
