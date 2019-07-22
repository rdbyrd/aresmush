module AresMUSH
  module Battle

    class BattleStopCommand
      include CommandHandler
      include NotAllowedWhileTurnInProgress

      attr_accessor :num

      def parse_args
        self.num = trim_arg(cmd.args)
      end

      def handle
        combat = Battle.find_combat_by_number(client, self.num)
        return if (!combat)

        #allow user to stop combat, print out their name on client
        Battle.emit_to_combat combat, t('battle.combat_stopped_by', :name => enactor_name)
        client.emit_success t('battle.stopping_combat', :num => self.num)

        combat.delete
        client.emit_success t('battle.combat_stopped', :num => self.num)
      end
    end
  end
end
