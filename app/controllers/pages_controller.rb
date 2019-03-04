class PagesController < ApplicationController
  def about
    @client_id = ENV["DISCORD_CLIENT_ID"] || ENV["DISCORD_CLIENT_ID_TEST"]
  end
end
