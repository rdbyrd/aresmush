module AresMUSH
  module Battle
    class BattleActionCommand

      attr_accessor :names, :action_args, :combat_command

      # parser function for handlilng user input for target names
      def parse_args
        if(cmd.args =~ /\=/)
          self.names = InputFormatter.titlecase_arg(cmd.args.before("="))
          self.action_args = cmd.args.after("=")
        elseif (cmd.args && one_word_command)
          self.names = InputFormatter.titlecase_arg(cmd.args)
          self.action_args = ""
        else
          self.names = enactor.name
          self.action_args = cmd.args
        end

        self.names = self.names ? self.names.split(/[ ,]/) : nil

        self.combat_command = cmd.switch ? cmd.switch.downcase : nil
      end

      #function to restrict the user from attacking under certain conditions
      def check_can_act
        return t('battle.you_are_not_in_combat') if !enactor.is_in_combat?
        return t('battle.cannot_act_while_koed') if (acting_for_self && enactor.combatant.is_ko)
        return t('battle.you_are_a_noncombatant') if (acting_for_self && enactor.combatant.is_noncombatant)
        return nil
      end

      #acting for self method imported from combat_action_cmd.rb. It's function is unclear, but referenced in other methods.
      def acting_for_self
        self.names &&
        self.names.count == 1 &&
        self.names[0] == enactor_name
      end

      #ensure a command can be recognized
      def handle
        action_klass = Battle.find_action_klass(self.combat_command)
        if (!action_klass)
          client.emit_failure t(battle.unknown_command)
          return
        end

        self.names.each do |name|

          Battle.with_a_combatant(name, client, enactor) do |combat, combatant|
            if (combatant.is_subdued? && self.combat_command != "escape")
              client.emit_failure t('battle.must_escape_first')
              next
            end
            Battle.set_action(client, enactor, combat, combatant, action_klass, self.action_args)
          end
        end
      end
    end
  end
end
