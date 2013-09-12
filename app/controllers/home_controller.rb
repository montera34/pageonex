class HomeController < ApplicationController
  def index
    @threads = Threadx.find(:coded_pages.length > 2, :limit=>10)
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
