module AresMUSH
  module BattleSkills
    class LuckAwardCommand
      include CommandHandler
      
      attr_accessor :name, :luck, :reason

      def parse_args
        args = command.parse_args(ArgParser.arg1_equals_arg2_slash_arg3)
        self.name = trim_arg(args.arg1)
        self.luck = trim_arg(args.arg2)
        self.reason = args.arg3
      end

      def required_args
        [ self.name, self.luck, self.reason ]
      end
      
      def check_luck
        return t('battleskills.invalid_luck_points') if !self.luck.is_integer?
        return nil
      end
      
      def check_can_award
        return nil if BattleSkills.can_manage_luck?(enactor)
        return t('dispatcher.not_allowed')
      end
      
      def handle
        ClassTargetFinder.with_a_character(self.name, client, enactor) do |model|
          model.award_luck(self.luck.to_i)
          Global.logger.info "#{self.luck} Luck Points Awarded by #{enactor_name} to #{model.name} for #{self.reason}"
          
          message = t('battleskills.luck_awarded', :name => model.name, :luck => self.luck, :reason => self.reason)
          client.emit_success message
          Mail.send_mail([model.name], t('battleskills.luck_award_mail_subject'), message, nil)          
          
        end
      end
    end
  end
end
