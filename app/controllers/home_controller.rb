class HomeController < ApplicationController
  def index
    @threads = Threadx.all
  end
  def about

  end
end
