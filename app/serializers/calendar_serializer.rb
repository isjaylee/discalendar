class CalendarSerializer
  include FastJsonapi::ObjectSerializer
  attributes :name

  attribute :events do |calendar|
    calendar.events.map {|event| EventSerializer.new(event) }
  end
end
