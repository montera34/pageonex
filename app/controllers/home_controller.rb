class HomeController < ApplicationController
  def index
    @threads = Threadx.last(16).reverse_order #selects the last 16 threads and reverses the order
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
