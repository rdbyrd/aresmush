module AresMUSH

  module BattleSkills
    class RollCommand
      include CommandHandler
      
      attr_accessor :name, :roll_str, :private_roll

      def parse_args
        if (command.args =~ /\//)
          args = command.parse_args(ArgParser.arg1_slash_arg2)          
          self.name = trim_arg(args.arg1)
          self.roll_str = titlecase_arg(args.arg2)
        else
          self.name = enactor_name        
          self.roll_str = titlecase_arg(command.args)
        end
        self.private_roll = command.switch_is?("private")
      end
      
      def required_args
        [ self.name, self.roll_str ]
      end
      
      def handle
        ClassTargetFinder.with_a_character(self.name, client, enactor) do |model|
          die_result = BattleSkills.parse_and_roll(model, self.roll_str)
          if !die_result
            client.emit_failure t('battleskills.unknown_roll_params')
            return
          end
          
          success_level = BattleSkills.get_success_level(die_result)
          success_title = BattleSkills.get_success_title(success_level)
          message = t('battleskills.simple_roll_result', 
            :name => model.name,
            :roll => self.roll_str,
            :dice => BattleSkills.print_dice(die_result),
            :success => success_title
          )
          BattleSkills.emit_results message, client, enactor_room, self.private_roll
        end
      end
    end
  end
end
