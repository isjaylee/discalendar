user = User.create!(username: "bob", password: "asdfasdf", provider: "discord", uid: "123")

calendar = user.calendars.create!(name: "Destiny 2")

event = calendar.events.create!(
  user: user,
  name: "Raid",
  starting: Time.now - 2.days,
  ending: Time.now - 2.days - 30.minutes,
  location: "PS4"
)

event.users << user