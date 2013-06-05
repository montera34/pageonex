module ThreadHelper

  # use this to link to a thread
  def thread_code_url thread, image_name=nil
    link = thread_url(thread) + "coding"
    link+= "/?i=#{image_name}" unless image_name.nil?
    link
  end

  def thread_url thread
    thread.link_url
  end

  def threads_by_user_link user
    link_to user.username, '/threads/by/'+user.username 
  end

end
