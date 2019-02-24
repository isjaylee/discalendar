class CalendarSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name

  attribute :events do |calendar|
    calendar.events.map {|event| EventSerializer.new(event) }
  end
end
