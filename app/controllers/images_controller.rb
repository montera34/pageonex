class ImagesController < ApplicationController

  def download
    image_id = params[:missing_image_id]
    thread_id = params[:thread_id]
    # try to download the image again
    image = Image.find(image_id)
    downloaded_something = image.download
    image.save
    # redirect back to the image in the thread
    thread = Threadx.find(thread_id)
    # TODO: should this flush the composite images on ALL the threads that use this image?
    thread.remove_composite_images if downloaded_something # flush the generated composite images because there is a new highlighted area
    redirect_to thread.link_url+"coding?i="+image.image_name
  end

end
