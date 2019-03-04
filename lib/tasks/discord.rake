namespace :discord do
  task run: :environment do
    # https://discordapp.com/oauth2/authorize?client_id=551973378475556864&scope=bot&permissions=448576
    token = ENV["DISCORD_TOKEN"] || ENV["DISCORD_TOKEN_TEST"]
    bot = Discordrb::Bot.new(token: token)

    WHITE_CHECK_MARK = "\u2705".force_encoding("utf-8").freeze

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
      if discord_event.user == discord_event.server.owner
        info = ParseHelper.strings_in_quotes(discord_event.message.content)
        starting =
          DateTime.strptime(info[1], '%m/%d/%Y %I:%M %p %Z')
          .in_time_zone("Central Time (US & Canada)")
          .strftime("%B %d, %Y at %l:%M%p Central")

        fields = [
          Discordrb::Webhooks::EmbedField.new(name: "Event", value: info[0]),
          Discordrb::Webhooks::EmbedField.new(name: "Starting", value: starting)
        ]

        embed = Discordrb::Webhooks::Embed.new(colour: "#69BB2D", fields: fields)
        message = discord_event.respond("#{info[0]} event created!", false, embed)

        DiscordBot.new(
          discord_event.server.name,
          discord_event.server.id,
          discord_event.user.username,
          discord_event.user.id,
          discord_event.user.discriminator
        ).create_event(message.id, discord_event.message.content)

        Discordrb::API::Channel.create_reaction(bot.token, message.channel.id, message.id, WHITE_CHECK_MARK)
      else
        discord_event.respond "Only the owner of the server can create an event."
      end
    end

    bot.message(start_with: "!discal edit event") do |discord_event|
      if discord_event.user == discord_event.server.owner
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
        discord_event.respond "Only the owner of the server can edit an event."
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