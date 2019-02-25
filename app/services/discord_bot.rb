class DiscordBot
  attr_reader :username, :uid, :content

  def initialize(username, uid, content)
    @username = username
    @uid = uid
    @content = content
  end

  def create_calendar
    # create calendar "Destiny 2"
    name = content.scan(/"([^"]*)"/).flatten.first
    user.calendars.create(name: name)
  end

  def create_event(discord_message_id)
    # create event "Destiny 2" "Raid" "02/24/2019 9:00PM CST"
    info = content.scan(/"([^"]*)"/).flatten
    calendar_name = info[0]
    event_name = info[1]
    starting = DateTime.strptime(info[2], '%m/%d/%Y %I:%M %p %Z')
    ending = DateTime.strptime(info[3], '%m/%d/%Y %I:%M %p') if info[3]
    calendar = user.calendars.find_by(name: calendar_name)
    calendar.events.create(name: event_name, starting: starting, ending: ending, discord_message_identifier: discord_message_id)
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
end