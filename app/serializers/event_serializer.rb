class EventSerializer
  include FastJsonapi::ObjectSerializer
  attributes :name, :location, :start, :end

  attribute :participants do |event|
    event.participants.map {|participant| ParticipantSerializer.new(participant) }
  end
end
