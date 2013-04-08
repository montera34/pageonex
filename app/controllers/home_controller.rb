class HomeController < ApplicationController
  def index
    @threads = Threadx.find(:all, :limit=>10)
  end
  def about

  end
end
