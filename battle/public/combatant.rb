module AresMUSH

  #get database connection for combat
  class Combatant < Ohm::Model
    include ObjectModel

    attribute :action_klass
    attribute :action_args
    attribute :combatant_type
    attribute :stance, :default => "Normal"
    attribute :is_ko, :type => DataType::Boolean
    attribute :idle, :type => DataType::Boolean
    attribute :posed, :type => DataType::Boolean
    attribute :team, :type => DataType::Integer, :default => 1

    reference :character, "AresMUSH::Character"
    reference :combat, "AresMUSH::Combat"

    attribute :damaged_by, :type => DataType::Array, :default => []

    before_delete :cleanup

    def cleanup
      self.clear_mock_damage
      self.npc.delete if self.npc
    end

    def action
      return nil if !self.action_klass
      klass = Battle.const_get(self.action_klass)
      a = klass.new(self, self.action_args)
      error = a.prepare

      if (error)
        self.combat.log "Action Reset: #{self.name} #{self.action_klass} #{self.action_args} #{error}"
        Battle.emit_to_combat self.combat, t('battle.resetting_action', :name => self.name, :error => error)
        self.update(action_klass: nil)
        self.update(action_args: nil)
        return nil
      end
      a
    end

    def is_passing?
      !self.action || self.action.class == Battle::PassAction
    end

    def associated_model
      is_npc? ? self.npc : self.character
    end

    def name
      is_npc? ? self.npc.name : self.character.name
    end

    def roll_ability(ability, mod = 0)
      result = is_npc? ? self.npc.roll_ability(ability, mod) : self.character.roll_ability(ability, mod)
      successes = result[:successes]
      log("#{self.name} rolling #{ability}: #{successes} successes")
      successes
    end

    def add_stress(points)
      points = [ self.stress + points, 5 ].min
      self.update(stress: points)
    end

    def client
      self.character ? Login.find_client(self.character) : nil
    end

    # NOTE!  This is reported as a negative number.
    def total_damage_mod
      if (is_in_vehicle?)
        Battle.total_damage_mod(self.associated_model) + Battle.total_damage_mod(self.vehicle)
      else
        Battle.total_damage_mod(self.associated_model)
      end
    end

    def inflict_damage(severity, desc, is_stun = false, is_crew_hit = false)
      if (self.is_in_vehicle? && !is_crew_hit)
        model = self.vehicle
      else
        model = self.associated_model
      end
      Battle.inflict_damage(model, severity, desc, is_stun, !self.combat.is_real)
    end

    def attack_stance_mod
      stance_config = Battle.stances[self.stance]
      return 0 if !stance_config
      stance_config["attack_mod"]
    end

    def defense_stance_mod
      stance_config = Battle.stances[self.stance]
      return 0 if !stance_config
      stance_config["defense_mod"]
    end

    def clear_mock_damage
      # Paranoia - should never happen unless there's a bug, but if it does happen it'll
      # prevent us from deleting the object.  So guard against it.
      if (!self.npc && !self.character)
        return
      end

      wounds = self.is_npc? ? self.npc.damage : self.character.damage
      wounds.each do |d|
        if (d.is_mock)
          d.delete
        end
      end
    end

    def is_noncombatant?
      self.combatant_type == "Observer"
    end

    def poss_pronoun
      self.is_npc? ? t('demographics.other_possessive') : Demographics.possessive_pronoun(self.character)
    end

    def log(msg)
      self.combat.log(msg)
    end
  end
end
