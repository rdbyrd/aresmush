module AresMUSH
  module Battle

    #handles system targeting
    class BattleTargetCommand
      include CommandHandler
      include NotAllowedWhileTurnInProgress

      attr_accessor :team, :targets

      def parse_args
        args = cmd.parse_args(ArgParser.arg1_equals_arg2)
        self.team = trim_arg(args.arg1).to_i
        self.targets = args.arg2 ? args.arg2.split(/[, ]/).map { |n| trim_arg(n).to_i } : nil
      end

      def required_args
        [ self.targets, self.team ]
      end

      #report error to user if team consists of less than 1 or more than 10 users
      def check_team
        return t('battle.invalid_team') if self.team < 1 || self.team > 9
        return t('battle.invalid_team') if self.targets.empty?
        self.targets.each do |t|
          return t('battle.invalid_team') if t < 1 || t > 9
        end
        return nil
      end

      #prevent user from taking unwanted action when not in combat
      def handle
        if (!enactor.is_in_combat?)
          client.emit_failure t('battle.you_are_not_in_combat')
          return
        end

        combat = enactor.combat
        team_targets = combat.team_targets || {}
        team_targets[self.team] = self.targets

        combat.update(team_targets: team_targets)

        Battle.emit_to_organizer combat, t('battle.team_target_set', :team => self.team, :targets => self.targets.join(", "))
      end
    end
  end
end
