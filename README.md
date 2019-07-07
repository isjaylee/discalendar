# Discalendar

A Discord bot to help manage events. Commands and any maintenance are all done
within Discord.

Tech stack:

* Ruby 2.6.1

* Rails 5.2

* Postgres for database

* Sidekiq for queuing the notifications of when an event is going to start

* React for the frontend (using webpacker)

* Discordrb for Discord API

## Files of special interest

Look at `discord.rake` and `discord_bot.rb` files for where most of the work
is being done.