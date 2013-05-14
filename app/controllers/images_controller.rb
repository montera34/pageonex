class ImagesController < ApplicationController

  def download
    image_id = params[:missing_image_id]
    thread_id = params[:thread_id]
    # try to download the image again
    image = Image.find(image_id)
    image.download
    image.save
    # redirect back to the image in the thread
    thread = Threadx.find(thread_id)
    redirect_to thread.link_url+"coding?i="+image.image_name
  end

end
