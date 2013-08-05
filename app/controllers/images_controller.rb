class ImagesController < ApplicationController
  
  before_filter :authenticate_admin!, :except => [:download]

  def download
    image_id = params[:missing_image_id]
    thread_id = params[:thread_id]
    # try to download the image again
    image = Image.find(image_id)
    downloaded_something = image.download
    image.save
    # redirect back to the image in the thread
    if thread_id=='0'
      # TODO: this needs to flush the composite image cache on all the threads that use this
      if downloaded_something
        flash[:notice] = "Download the image"
      else
        flash[:error] = "Didn't download anything!"
      end
      redirect_to '/images/'+image_id
    else
      thread = Threadx.find(thread_id)
      # TODO: should this flush the composite images on ALL the threads that use this image?
      thread.remove_composite_images if downloaded_something # flush the generated composite images because there is a new highlighted area
      redirect_to thread.link_url+"coding?i="+image.id.to_s
    end
  end

  def for_media
    @images = Image.where(:media_id=>params[:media_id])
    render :index
  end

  # GET /images
  # GET /images.json
  def index
    @images = Image.all(:limit=>100)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @images }
    end
  end

  # GET /images/1
  # GET /images/1.json
  def show
    @image = Image.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @image }
    end
  end

  # GET /images/new
  # GET /images/new.json
  def new
    @image = Image.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @image }
    end
  end

  # GET /images/1/edit
  def edit
    @image = Image.find(params[:id])
  end

  # POST /images
  # POST /images.json
  def create
    @image = Image.new(params[:image])

    respond_to do |format|
      if @image.save
        format.html { redirect_to @image, notice: 'Image was successfully created.' }
        format.json { render json: @image, status: :created, location: @image }
      else
        format.html { render action: "new" }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /images/1
  # PUT /images/1.json
  def update
    @image = Image.find(params[:id])

    respond_to do |format|
      if @image.update_attributes(params[:image])
        format.html { redirect_to @image, notice: 'Image was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /images/1
  # DELETE /images/1.json
  def destroy
    @image = Image.find(params[:id])
    @image.destroy

    respond_to do |format|
      format.html { redirect_to images_url }
      format.json { head :no_content }
    end
  end
end
