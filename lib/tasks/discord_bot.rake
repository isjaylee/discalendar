namespace :discord do
  task run: :environment do
    bot = Discordrb::Bot.new(token: "NTQ4OTUxMzM0Nzc1MjkxOTM2.D1Ro5Q.O9M06sm2jQaOGoi-zCujhrBnTh4")

    bot.message(start_with: "create calendar") do |event|
      calendar = DiscordBot.new(event.user.username, event.user.id, event.message.content).create_calendar()
      event.respond "#{calendar.name} calendar created!"
    end

    bot.message(start_with: "create event") do |event|
      info = ParseHelper.strings_in_quotes(event.message.content)
      starting =
        DateTime.strptime(info[2], '%m/%d/%Y %I:%M %p %Z')
        .in_time_zone("Central Time (US & Canada)")
        .strftime("%B %d, %Y at %l:%M%p Central")

      fields = [
        Discordrb::Webhooks::EmbedField.new(name: "Name", value: info[0]),
        Discordrb::Webhooks::EmbedField.new(name: "Starting", value: starting)
      ]

      embed = Discordrb::Webhooks::Embed.new(colour: "#69BB2D", fields: fields)
      message = event.respond("#{info[1]} event created!", false, embed)

      DiscordBot.new(event.user.username, event.user.id, event.message.content).create_event(message.id)
      Discordrb::API::Channel.create_reaction(bot.token, message.channel.id, message.id, "✅")
    end

    bot.reaction_add do |event|
      participant = DiscordBot.new(event.user.username, event.user.id, event.message.content).create_participant(event.message.id)
    end

    bot.reaction_remove do |event|
      participant = DiscordBot.new(event.user.username, event.user.id, event.message.content).remove_participant(event.message.id)
    end

    bot.run
  end
end