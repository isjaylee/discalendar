namespace :discord do
  task run: :environment do
    # https://discordapp.com/oauth2/authorize?client_id=551973378475556864&scope=bot&permissions=448576
    token = ENV["DISCORD_TOKEN"] || ENV["DISCORD_TOKEN_TEST"]
    bot = Discordrb::Bot.new(token: token)

    WHITE_CHECK_MARK = "\u2705".force_encoding("utf-8").freeze

    bot.message(start_with: "!discal help") do |discord_event|
      fields = [
        Discordrb::Webhooks::EmbedField.new(name: "!discal create calendar", value: "This is probably the first command you'll want to run. It creates a calendar for the server. Only the owner of the server can create a calendar"),
        Discordrb::Webhooks::EmbedField.new(name: "!discal join calendar", value: "Join the calendar of the server you are in. This does not happen by default, so if you are in a server that has a calendar, you will need to run this command to join the calendar."),
        Discordrb::Webhooks::EmbedField.new(name: "!discal create event \"name\" \"date\"", value: "Create event on the given calendar/server. Example: !discal create event \"Raid\" \"02/24/2019 9:00PM CST\""),
        Discordrb::Webhooks::EmbedField.new(name: "!discal edit event \"message_id\" \"name\" \"date\" ", value: "Edit an existing event. Example: !discal edit event \"1234567\" \"Nightfall\" \"02/24/2019 10:00PM CST\" "),
        Discordrb::Webhooks::EmbedField.new(name: "Reacting to an event", value: "When an event is created, the event is shown and the :white_check_mark: emoji will appear. When a user clicks on that emoji, they will be added as a participant of the event.
Similarly, if a user has reacted to the event and now wants to retract their reaction (by clicking on it again), the user will be removed from the event.")
      ]

      embed = Discordrb::Webhooks::Embed.new(colour: "#69BB2D", fields: fields)
      message = "Commands are below. For more information, please visit https://www.discalendar.com/about"
      message = discord_event.respond(message, false, embed)
    end

    bot.message(start_with: "!discal create calendar") do |discord_event|
      if discord_event.user == discord_event.server.owner
        calendar = DiscordBot.new(
          discord_event.server.name,
          discord_event.server.id,
          discord_event.user.username,
          discord_event.user.id,
          discord_event.user.discriminator
        ).create_calendar()

        if calendar.save
          discord_event.respond "#{calendar.name} calendar created"
        else
          discord_event.respond "#{calendar.errors.messages[:name].first}"
        end
      else
        discord_event.respond "Only the owner of the server can create a calendar."
      end
    end

    bot.message(start_with: "!discal join calendar") do |discord_event|
      calendar = DiscordBot.new(
        discord_event.server.name,
        discord_event.server.id,
        discord_event.user.username,
        discord_event.user.id,
        discord_event.user.discriminator
      ).join_calendar()

      discord_event.respond "You've joined the calendar!"
    end

    bot.message(start_with: "!discal create event") do |discord_event|
      if discord_event.user.permission?(:manage_server, discord_event.channel)
        info = ParseHelper.strings_in_quotes(discord_event.message.content)
        starting_date = DateTime.strptime(info[1], '%m/%d/%Y %I:%M %p %Z')

        if !(starting_date >= Time.now && starting_date < Time.now + 3.months)
          discord_event.respond "Events can only be created in the future and cannot be more than 3 months from now."
          next
        end

        starting_message =
          starting_date
          .in_time_zone("Central Time (US & Canada)")
          .strftime("%B %d, %Y at %l:%M%p Central")

        fields = [
          Discordrb::Webhooks::EmbedField.new(name: "Event", value: info[0]),
          Discordrb::Webhooks::EmbedField.new(name: "Starting", value: starting_message)
        ]

        embed = Discordrb::Webhooks::Embed.new(colour: "#69BB2D", fields: fields)
        message = discord_event.respond("#{info[0]} event created! Click on the white checkmark to RSVP.", false, embed)

        event = DiscordBot.new(
          discord_event.server.name,
          discord_event.server.id,
          discord_event.user.username,
          discord_event.user.id,
          discord_event.user.discriminator
        ).create_event(message.id, discord_event.message.content)

        Discordrb::API::Channel.create_reaction(bot.token, message.channel.id, message.id, WHITE_CHECK_MARK)
        EventNotificationJob.set(wait_until: event.starting - 10.minutes).perform_later(bot.token, message.channel.id, event.id)
      else
        discord_event.respond "Only the server managers can create an event."
      end
    end

    bot.message(start_with: "!discal edit event") do |discord_event|
      if discord_event.user.permission?(:manage_server, discord_event.channel)
        content = ParseHelper.strings_in_quotes(discord_event.message.content)
        event = Event.find_by(discord_message_identifier: content[0])
        starting =
          DateTime.strptime(content[2], '%m/%d/%Y %I:%M %p %Z')
          .in_time_zone("Central Time (US & Canada)")
          .strftime("%B %d, %Y at %l:%M%p Central")

        fields = [
          Discordrb::Webhooks::EmbedField.new(name: "Old Event Name", value: event.name),
          Discordrb::Webhooks::EmbedField.new(name: "New Event Name", value: content[1]),
          Discordrb::Webhooks::EmbedField.new(name: "Starting", value: starting)
        ]

        DiscordBot.new(
          discord_event.server.name,
          discord_event.server.id,
          discord_event.user.username,
          discord_event.user.id,
          discord_event.user.discriminator
        ).edit_event(content)

        embed = Discordrb::Webhooks::Embed.new(colour: "#69BB2D", fields: fields)
        message = discord_event.respond("An event has been updated!", false, embed)

        Discordrb::API::Channel.create_reaction(bot.token, message.channel.id, message.id, WHITE_CHECK_MARK)
      else
        discord_event.respond "Only server managers can edit an event."
      end
    end

    bot.message(start_with: "!discal delete event") do |discord_event|
      if discord_event.user.permission?(:manage_server, discord_event.channel)
        content = ParseHelper.strings_in_quotes(discord_event.message.content)
        message_id = content[0]
        event = Event.find_by(discord_message_identifier: message_id)
        event_name = event.name
        starting =
          event.starting
          .in_time_zone("Central Time (US & Canada)")
          .strftime("%B %d, %Y at %l:%M%p Central")

        DiscordBot.new(
          discord_event.server.name,
          discord_event.server.id,
          discord_event.user.username,
          discord_event.user.id,
          discord_event.user.discriminator
        ).delete_event(event.discord_message_identifier)

        Discordrb::API::Channel.delete_message(bot.token, discord_event.channel.id, message_id)
        discord_event.respond "The #{event_name} event happening at #{starting} has been cancelled."
      else
        discord_event.respond "Only server managers can delete an event."
      end
    end

    bot.reaction_add(emoji: WHITE_CHECK_MARK) do |discord_event|
      event = Event.where(discord_message_identifier: discord_event.message.id)
      if event
        participant = DiscordBot.new(
          discord_event.server.name,
          discord_event.server.id,
          discord_event.user.username,
          discord_event.user.id,
          discord_event.user.discriminator
        ).create_participant(discord_event.message.id)
      end
    end

    bot.reaction_remove(emoji: "\u2705".force_encoding("utf-8")) do |discord_event|
      event = Event.where(discord_message_identifier: discord_event.message.id)
      if event
        participant = DiscordBot.new(
          discord_event.server.name,
          discord_event.server.id,
          discord_event.user.username,
          discord_event.user.id,
          discord_event.user.discriminator
        ).remove_participant(discord_event.message.id)
      end
    end

    bot.run
  end
end