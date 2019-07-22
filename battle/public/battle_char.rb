module AresMUSH
  module Character
    collection :damage, "AresMUSH::Damage"
    attribute :combats_participated_in, :type => DataType::Integer

    before_delete :delete_damage

    #find the user and mark them as combatant in order of id
    def combatant
      Combatant.find(character_id: self.id).first
    end

    def is_in_combat?
      #mark in combat for combatant as true.
      !!combatant
    end

    def combat
      self.comatant ? self.combatant.combat : nil
    end
  end
end
