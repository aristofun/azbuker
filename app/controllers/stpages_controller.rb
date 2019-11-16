class StpagesController < ApplicationController
  require 'actionpack/action_caching'

  caches_action :error_404, :error_500

  def error_500
    render status: :internal_server_error unless forcache
  end

  def error_404
    render status: :not_found unless forcache
  end

  private

  def forcache
    params[:forcache]
  end
end
