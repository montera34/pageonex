class MediaController < ApplicationController
  
   before_filter :authenticate_admin!
   
  # GET /media
  # GET /media.json
  def index
    @media_list = Media.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @media_list }
    end
  end

  # GET /media/1
  # GET /media/1.json
  def show
    @media = Media.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @media }
    end
  end

  # GET /media/new
  # GET /media/new.json
  def new
    @media = Media.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @media }
    end
  end

  # GET /media/1/edit
  def edit
    @media = Media.find(params[:id])
  end

  # POST /media
  # POST /media.json
  def create
    @media = Media.new(params[:media])

    respond_to do |format|
      if @media.save
        format.html { redirect_to @media, notice: 'Media was successfully created.' }
        format.json { render json: @media, status: :created, location: @media }
      else
        format.html { render action: "new" }
        format.json { render json: @media.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /media/1
  # PUT /media/1.json
  def update
    @media = Media.find(params[:id])

    respond_to do |format|
      if @media.update_attributes(params[:media])
        format.html { redirect_to @media, notice: 'Media was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @media.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /media/1
  # DELETE /media/1.json
  def destroy
    @media = Media.find(params[:id])
    @media.destroy

    respond_to do |format|
      format.html { redirect_to media_url }
      format.json { head :no_content }
    end
  end
end
