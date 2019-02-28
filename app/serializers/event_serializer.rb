class EventSerializer
  include FastJsonapi::ObjectSerializer
  attributes :name, :location, :starting, :ending

  attribute :calendar do |event|
    event.calendar
  end

  attribute :participants do |event|
    event.participants.map {|participant| ParticipantSerializer.new(participant) }
  end
end
