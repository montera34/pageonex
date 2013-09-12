class HomeController < ApplicationController
  def index
    @threads = Threadx.find(:all, :limit=>10) if Threadx.coded_image_ids != []
  end
  def about

  end
  def export_chart
    Tempfile.open(['chart', '.svg'], Rails.root.join('tmp')) do |f|
      f.print params[:svgdata]
      f.flush
      send_file f.path, :type => 'image/svg+xml'
    end
  end
end
