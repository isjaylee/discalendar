class EventNotificationJob < ApplicationJob
  queue_as :default
  WHITE_CHECK_MARK = "\u2705".force_encoding("utf-8").freeze

  def perform(token, channel_id, event_id)
    event = Event.find(event_id)
    participants = 
      if event.participants.present?
        event.participants.joins(:user).pluck(:username).join(", ")
      else
        "No one yet. Be the first!"
      end

    starting =
      event.starting
      .in_time_zone("Central Time (US & Canada)")
      .strftime("%B %d, %Y at %l:%M%p Central")

    fields = [
      Discordrb::Webhooks::EmbedField.new(name: "Event", value: event.name),
      Discordrb::Webhooks::EmbedField.new(name: "Starting", value: starting),
      Discordrb::Webhooks::EmbedField.new(name: "Going", value: participants)
    ]

    embed = Discordrb::Webhooks::Embed.new(colour: "#69BB2D", fields: fields)
    notification = "#{event.name} is starting in 10 minutes. Let others know you're joining by clicking the white checkmark!"
    message = Discordrb::API::Channel.create_message(token, channel_id, notification, false, embed)
    event.update_attributes(discord_message_identifier: JSON.parse(message)["id"])
    Discordrb::API::Channel.create_reaction(token, channel_id, JSON.parse(message)["id"], WHITE_CHECK_MARK)
  end
end
