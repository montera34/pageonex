class CodingController < ApplicationController
  before_filter :authenticate_user!, :except => :display

  def process_images
    @thread = Threadx.find_by_thread_name params[:thread_name]
    @image_counter = @thread.images.length
    @highlighted_areas = []

    # add only the hightlighted area related to existing images
    # @thread.highlighted_areas.each do |ha|
    #   @highlighted_areas << ha if @thread.images.include? ha.image
    # end
    @highlighted_areas = @thread.highlighted_areas

    @images = @thread.images.sort do |img1, img2|
      img1.publication_date <=> img2.publication_date
    end
    # render json: @images.to_json

  end

  def process_highlighted_areas
    @thread = Threadx.find_by_thread_name params[:thread_name]
    @images = @thread.images.sort do |img1, img2|
      img1.publication_date <=> img2.publication_date
    end

    @image_counter = @thread.images.length

    @thread.highlighted_areas.each do |ha|
      if params["#{ha.name}_status"] == "1"
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

    redirect_to "/users/#{current_user.username.split(' ').join('_')}/threads/#{@thread.thread_name}"
    # render json: params.to_json
  end

  def display
    @thread = Threadx.find_by_thread_name params[:thread_name]
    
    # sort images by their publication date
    @images = @thread.images.sort do |img1, img2|
      img1.publication_date <=> img2.publication_date
    end
    
    @image_counter = @thread.images.length
    @codes = @thread.codes
    

    
    # add only the hightlighted area related to existing images
    # @thread.highlighted_areas.each do |ha|
    #   @highlighted_areas << ha if @thread.images.include? ha.image
    # end
    @highlighted_areas = @thread.highlighted_areas

    
    # sort highlighted areas by the image name
    # change this
    @highlighted_areas.sort! do |ha1,ha2|
    	ha1.name.split('_')[0][5..100].to_i <=> ha2.name.split('_')[0][5..100].to_i
    end


    # This part is used to calculate the highlighted areas percentages vertically 
    @images_columns = {}

    @high_areas_per = {}
    
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

    @images_columns .each do |cr,imgs|
      
      imgs.each do |img|
        
        img.highlighted_areas.each do |ha|
          if @codes.include? ha.code
            highlighted_area = ha.areas[0]["height"].to_f * ha.areas[0]["width"].to_f
            image_area = ha.image.size.split("x")[0].to_f * ha.image.size.split("x")[1].to_f
            ratio = (highlighted_area / image_area) * 100
            @high_areas_per[cr] << ratio.ceil
          end
        end

      end

    end

    c = 0.0
    @high_areas_per.each do |cr,rs|
      rs.each do |r|
        c += r.to_i
      end
      @ratios[cr[1..cr.length]] = c / @thread.media.length
      c = 0.0
    end
    # end of the calculating and store the results in @ratios hash

    # render json: @ratios


  end
end
