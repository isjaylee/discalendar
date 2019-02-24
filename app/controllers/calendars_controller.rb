class CalendarsController < ApplicationController
  before_action :authenticate_user!
  respond_to :html, :json

  def index
    discord.get_servers()
    @calendar = current_user.calendars&.first

    respond_to do |format|
      format.html { @calendar }
      format.json { render json: { calendar: @calendar, events: @calendar.events } }
    end
  end

  private
    def discord
      DiscordApi.new(session[:discord_token])
    end
end
