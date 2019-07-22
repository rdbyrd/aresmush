module AresMUSH
  module Battle
    class Aim

      #find if there are any valid targets to hit beyond player character. If not, return error
      def prepare
        error = parse_targets(self.action_args)
        return error if error

        return t('battle.only_one_target') if (self.targets.count > 1)
        return nil
      end

      #make a concise print of the target names
      def print_action
        t('battle.aim_action_msg_short', :name => self.name, :target => self.print_names)
      end

      #update target being targeted within the database when in battle
      def resolve
        self.combatant.update(aim_target: self.target)
        [t('battle.aim_resolution_msg', :name => self.name, :target => self.print_target_names)]
      end
    end
  end
end
