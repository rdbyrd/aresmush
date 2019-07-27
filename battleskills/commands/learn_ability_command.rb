module AresMUSH

  module BattleSkills
    class LearnAbilityCommand
      include CommandHandler
      
      attr_accessor :name

      def parse_args
        self.name = titlecase_arg(command.args)
      end

      def required_args
        [ self.name ]
      end
      
      def check_chargen_locked
        return t('battleskills.must_be_approved') if !enactor.is_approved?
        return nil
      end
      
      def check_xp
        return t('battleskills.not_enough_xp') if enactor.xp <= 0
      end
      
      def handle
        error = BattleSkills.learn_ability(enactor, self.name)
        if (error)
          client.emit_failure error
        else
          client.emit_success t('battleskills.xp_spent', :name => self.name)
        end
      end
    end
  end
end
