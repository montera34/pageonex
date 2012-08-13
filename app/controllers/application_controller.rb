class ApplicationController < ActionController::Base
  protect_from_forgery
  Rack::Utils.key_space_limit = 1000000000
end
