class DiscordApi
  attr_reader :token

  BASE_URL = "https://discordapp.com/api".freeze

  def initialize(token)
    @token = token
  end

  def get_servers
    response = HTTP.auth("Bearer #{token}").get("#{BASE_URL}/users/@me/guilds")
    data = JSON.parse(response.body.to_s)
  end
end