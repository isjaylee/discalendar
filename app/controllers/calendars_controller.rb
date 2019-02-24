class CalendarsController < ApplicationController
  before_action :authenticate_user!
  respond_to :html, :json

  def index
    discord.get_servers()
    @calendars = current_user.calendars
    data = CalendarSerializer.new(@calendars).serialized_json

    respond_to do |format|
      format.html { @calendar }
      format.json { render json: data }
    end
  end

  private
    def discord
      DiscordApi.new(session[:discord_token])
    end
end
