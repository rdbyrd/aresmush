module AresMUSH
  module Battle

    #give limits to team sizes
    class BattleTeamCommand
      include CommandHandler
      include NotAllowedWhileTurnInProgress

      attr_accessor :names, :team

      def parse_args
        if (cmd.args =~ /=/)
          args = cmd.parse_args(ArgParser.arg1_equals_arg2)
          self.names = titlecase_list_arg(args.arg1)
          self.team = trim_arg(args.arg2).to_i
        else
          self.names = [enactor.name]
          self.team = trim_arg(cmd.args).to_i
        end
      end

      def required_args
        [ self.names, self.team ]
      end

      #disallow a team from exceeding 9 or being less than 1 unit
      def check_team
        return t('battle.invalid_team') if self.team < 1 || self.team > 9
        return nil
      end

      #format team combatants through outputting them as an array
      def handle
        self.names.each do |name|
          Battle.with_a_combatant(name, client, enactor) do |combat, combatant|
            combatant.update(team: team)
            message = t('battle.team_set', :name => name, :team => self.team)
            Battle.emit_to_combat combat, message, Battle.npcmaster_text(name, enactor)
          end
        end
      end
    end
  end
end
