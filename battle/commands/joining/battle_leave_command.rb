module AresMUSH
  module Battle

    #leaving battle is not the same as stopping it. To stop combat, a user cognitively does it.
    #(i.e. "Combat stopped by <name>.")
    #Instead, this class allows the server to recognize that a unit has stopped being a combatant.
    class BattleLeaveCommand

      include CommandHandler
      include NotAllowedWhileTurnInProgress

      attr_accessor :names

      #ensure names are right
      def parse_args
        self.names = cmd.args ? list_arg(cmd.args) : [enactor.name]
      end

      #remove user from combat, marking them non-combatant and disallowing unwanted combat actions
      def handle
        self.names.each do |name|
          Battle.with_a_combatant(name, client, enactor) do |combat, combatant|
            Battle.leave_combat(combat, combatant)
          end
        end
      end
    end
  end
end
