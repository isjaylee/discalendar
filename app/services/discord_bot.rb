class DiscordBot
  attr_reader :server_name, :server_id, :username, :uid, :content

  def initialize(server_name, server_id, username, uid)
    @server_name = server_name
    @server_id = server_id
    @username = username
    @uid = uid
  end

  def create_calendar
    # !create calendar
    calendar = user.calendars.new(name: @server_name, discord_identifier: @server_id)
  end

  def create_event(discord_message_id)
    # !create event "Raid" "02/24/2019 9:00PM CST"
    info = content.scan(/"([^"]*)"/).flatten
    event_name = info[0]
    starting = DateTime.strptime(info[1], '%m/%d/%Y %I:%M %p %Z')
    ending = DateTime.strptime(info[2], '%m/%d/%Y %I:%M %p') if info[2]

    params = {
      user: user,
      name: event_name,
      discord_message_identifier: discord_message_id,
      starting: starting,
      ending: ending
    }

    event = calendar.events.create(params)
  end

  def create_participant(discord_message_id)
    event = get_event(discord_message_id)
    user.events << event unless user.events.include?(event)
  end

  def remove_participant(discord_message_id)
    event = get_event(discord_message_id)
    Participant.find_by(user: user, event: event).destroy
  end

  private
    def user
      User.where(provider: "discord", uid: uid, username: username).first_or_create do |user|
        user.password = Devise.friendly_token[0, 20]
      end
    end

    def get_event(discord_message_id)
      Event.find_by(discord_message_identifier: discord_message_id)
    end

    def calendar
      user.calendars.find_by(discord_identifier: @server_id)
    end
end