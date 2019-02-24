class CalendarsController < ApplicationController
  before_action :authenticate_user!

  def index
    discord.get_servers()
  end

  private
    def discord
      DiscordApi.new(session[:discord_token])
    end
end
