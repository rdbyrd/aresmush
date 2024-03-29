module AresMUSH
  class BattleAction

    # arguments for setting up combatants, names, actions, and targets
    attr_accessor :combatant, :name, :action_args, :targets

    def initialize(combatant, args)
      self.combatant = combatant
      self.action_args = args
      self.targets = []
    end

    def name
      self.combatant.name
    end

    def combat
      self.combatant.combat
    end

    def parse_targets(name_string)
      return t('battle.no_targets_specified') if (!name_string)
      target_names = name_string.split(" ").map { |n| InputFormatter.titlecase_arg(n) }
      targets = []
      target_names.each do |name|
        target = self.combat.find_combatant(name)
        return t('battle.not_in_combat', :name => name) if !target
        return t('battle.cant_target_noncombatant', :name => name) if target.is_noncombatant?
        targets << target
      end
      self.targets = targets
      return nil
    end

    def target
      targets ? targets[0] : nil
    end

    def target_names
      self.targets.map { |t| t.name }
    end

    def print_target_names
      self.target_names.join(" ")
    end
  end
end
