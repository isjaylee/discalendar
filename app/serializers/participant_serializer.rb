class ParticipantSerializer
  include FastJsonapi::ObjectSerializer

  attribute :user do |participant|
    UserSerializer.new(participant.user)
  end
end
