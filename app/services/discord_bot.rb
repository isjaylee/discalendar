class DiscordBot
  attr_reader :server_name, :server_id, :username, :uid, :discriminator

  def initialize(server_name, server_id, username, uid, discriminator)
    @server_name = server_name
    @server_id = server_id
    @username = "#{username}#{discriminator}"
    @uid = uid
    @discriminator = discriminator
  end

  def create_calendar
    # !create calendar
    user.calendars.new(name: @server_name, discord_identifier: @server_id)
  end

  def join_calendar
    # !join calendar
    calendar.users << user unless calendar.users.include?(user)
  end

  def create_event(discord_message_id, content)
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

    calendar.events.create(params)
  end

  def create_participant(discord_message_id)
    event = get_event(discord_message_id)
    event.users << user unless event.users.include?(user)
    calendar.users << user unless calendar.users.include?(user)
  end

  def remove_participant(discord_message_id)
    event = get_event(discord_message_id)
    Participant.find_by(user: user, event: event).destroy
  end

  private
    def user
      user = User.where(uid: @uid).first_or_create
      user.update_attributes(
        username: @username,
        provider: "discord"
      )
      user
    end

    def get_event(discord_message_id)
      Event.find_by(discord_message_identifier: discord_message_id)
    end

    def calendar
      Calendar.find_by(discord_identifier: @server_id)
    end
end