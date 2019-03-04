require_relative "../test_helper"

class DiscordBotTest < ActiveSupport::TestCase

  setup do
    @bot = DiscordBot.new("Acme Server", "1234", "owner123", "123", "123")
    @owner = users(:owner)
    @user = users(:user)
  end

  def test_create_event
    @bot.create_event("123", '"Raid" "03/03/2019 9:00PM CST"')
    event = Event.find_by(discord_message_identifier: "123")
    assert event.present?
  end

  def test_create_event_fails
    @bot.create_event("123", '"Raid" "03/03/2019 9:00PM CST"')
    event = Event.find_by(discord_message_identifier: "12")
    assert event.nil?
  end

  def test_edit_event
    @bot.create_event("123", '"Raid" "03/03/2019 9:00PM CST"')
    @bot.edit_event(["123", "Nightfall", "03/03/2019 9:00PM CST"])
    event = Event.find_by(discord_message_identifier: "123")
    assert event.name == "Nightfall"
  end

  def test_create_calendar
    calendar = @bot.create_calendar.save
    assert @owner.calendars.includes(calendar)
  end

  def test_join_calendar
    @bot = DiscordBot.new("Acme Server", "456", "user456", "456", "456")
    calendar = @bot.create_calendar.save
    @bot.join_calendar
    assert @user.calendars.includes(calendar)
  end
end