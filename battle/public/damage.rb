module AresMUSH

  class Damage < Ohm::Model
    include ObjectModel

    attribute :current_severity
    attribute :initial_severity
    attribute :ictime_str
    attribute :description
    attribute :is_mock, :type => DataType::Boolean

    reference :character, "AresMUSH::Character"

    def is_stun?
      is_stun
    end

    def wound_mod
      config = Global.read_config("battle", "damage_mods")
      mod = config[self.current_severity]
      mod = mod / 3.0 if self.healed
      mod
    end
  end
end
