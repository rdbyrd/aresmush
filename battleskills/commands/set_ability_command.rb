module AresMUSH

  module BattleSkills
    class SetAbilityCommand
      include CommandHandler
      
      attr_accessor :name, :ability_name, :rating
      
      def parse_args
        if (command.args =~ /[^\/]+\=.+\/.+/)
          args = command.parse_args(ArgParser.arg1_equals_arg2_slash_arg3)
          self.name = trim_arg(args.arg1)
          self.ability_name = titlecase_arg(args.arg2)
          self.rating = trim_arg(args.arg3)
        else
          args = command.parse_args(ArgParser.arg1_equals_arg2)
          self.name = enactor_name
          self.ability_name = titlecase_arg(args.arg1)
          self.rating = trim_arg(args.arg2)
        end
      end

      def required_args
        [ self.name, self.ability_name, self.rating ]
      end
      
      def check_valid_rating
        return nil if !self.rating
        return t('battleskills.invalid_rating') if !self.rating.is_integer?
        return nil
      end
      
      def check_can_set
        return nil if enactor_name == self.name
        return nil if BattleSkills.can_manage_abilities?(enactor)
        return t('dispatcher.not_allowed')
      end      
      
      def check_chargen_locked
        return nil if BattleSkills.can_manage_abilities?(enactor)
        Chargen.check_chargen_locked(enactor)
      end
      
      def handle
        ClassTargetFinder.with_a_character(self.name, client, enactor) do |model|        
          new_rating = self.rating.to_i
          error = BattleSkills.check_rating(self.ability_name, new_rating)
          if (error)
            client.emit_failure error
            return
          end
          
          error = BattleSkills.set_ability(model, self.ability_name, new_rating)
          if (error)
            client.emit_failure error
          else
            client.emit_success BattleSkills.ability_raised_text(model, self.ability_name)
          end
          
        end
      end
    end
  end
end
