class CalendarsController < ApplicationController
  before_action :authenticate_user!
  respond_to :html, :json

  def index
    discord.get_servers()
    @calendars = current_user.calendars
    @participated_calendars = Calendar.joins({events: :participants}).where(events: {participants: {user: current_user}})
    calendars_data = CalendarSerializer.new(@calendars).serialized_json
    participated_calendars_data = CalendarSerializer.new(@participated_calendars).serialized_json
    data = { your_calendars: JSON.parse(calendars_data), participated_calendars: JSON.parse(participated_calendars_data) }

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
