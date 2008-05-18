

class ApplicationController < ActionController::Base
  include AuthenticatedSystem

  helper :all

  protect_from_forgery :secret => '52a28dfd46591a86a1697488dfb870e8'
end