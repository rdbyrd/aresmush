module AresMUSH
  module Battle
    class BattleUnknownCommand
      include CommandHandler
      include NotAllowedWhileTurnInProgress

      attr_accessor :name

      #check for appropriate capitalization in user name
      def parse_args
        self.name = titlecase_arg(cmd.args)
      end

      def required_args
        [ self.name ]
      end

      #handle the combatant and the combat.
      def handle
        Battle.with_a_combatant(self.name, client, enactor) do |combat, combatant|

          if (combat.organizer != enactor)
            client.emit_failure t('battle.only_organizer_can_do')
            return
          end

          combatant.update(is_ko: false)
          client.emit_success t('battle.is_no_longer_koed', :name => self.name)
        end
      end
    end
  end
end
