class CalendarSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name

  attribute :events do |calendar|
    calendar.events.order(:starting, starting: :desc).map {|event| EventSerializer.new(event) }
  end
end
