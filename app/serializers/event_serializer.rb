class EventSerializer
  include FastJsonapi::ObjectSerializer
  attributes :name, :location, :starting, :ending

  attribute :participants do |event|
    event.participants.map {|participant| ParticipantSerializer.new(participant) }
  end
end
