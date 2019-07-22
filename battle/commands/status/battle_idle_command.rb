module AresMUSH
  module Battle

    class BattleIdleCommand
      include CommandHandler
      include NotAllowedWhileTurnInProgress

      attr_accessor :name

      def parse_args
        self.name = titlecase_arg(cmd.args)
      end

      def required_args
        [ self.name ]
      end

      def handle
        Battle.with_a_combatant(self.name, client, enactor, enactor) do |combat, combatant|

          if (combat.organizer != enactor)
            client.emit_failure t('battle.only_organizer_can_do')
            return
          end

          #remove idle tag on user
          if (combatant.idle)
            combatant.update(idle: false)
            client.emit_success t('battle.marked_unidle', :name => self.name)
          else

            #mark user for idle
            combatant.update(idle: true)
            client.emit_success t('battle.marked_idle', :name => self.name)
          end
        end
      end
    end
  end
end
