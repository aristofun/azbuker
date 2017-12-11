class StpagesController < ApplicationController
  caches_page :error_404, :error_500

  def error_500
    unless params[:forcache]
      render :status => 500
    end
  end

  def error_404
    unless params[:forcache]
      render :status => 404
    end
  end
end
