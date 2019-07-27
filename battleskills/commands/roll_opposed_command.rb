module AresMUSH

  module BattleSkills
    class OpposedRollCommand
      include CommandHandler
      
      attr_accessor :name1, :name2, :roll_str1, :roll_str2

      def parse_args
        args = command.parse_args( /(?<name1>[^\/]+)\/(?<str1>.+) vs (?<name2>[^\/]+)?\/?(?<str2>.+)/ )
        self.roll_str1 = titlecase_arg(args.str1)
        self.roll_str2 = titlecase_arg(args.str2)
        self.name1 = titlecase_arg(args.name1)
        self.name2 = titlecase_arg(args.name2)
      end

      def required_args
        [ self.name1, self.roll_str1, self.roll_str2 ]
      end
      
      def handle
        
        result = ClassTargetFinder.find(self.name1, Character, enactor)
        model1 = result.target
        if (!model1 && !self.roll_str1.is_integer?)
          client.emit_failure t('battleskills.numbers_only_for_npc_skills')
          return
        end
                                
        if (self.name2)
          result = ClassTargetFinder.find(self.name2, Character, enactor)
          model2 = result.target
          self.name2 = !model2 ? self.name2 : model2.name
        end
                                
        if (!model2 && !self.roll_str2.is_integer?)
          client.emit_failure t('battleskills.numbers_only_for_npc_skills')
          return
        end
          
        die_result1 = BattleSkills.parse_and_roll(model1, self.roll_str1)
        die_result2 = BattleSkills.parse_and_roll(model2, self.roll_str2)
          
        if (!die_result1 || !die_result2)
          client.emit_failure t('battleskills.unknown_roll_params')
          return
        end
          
        successes1 = BattleSkills.get_success_level(die_result1)
        successes2 = BattleSkills.get_success_level(die_result2)
            
        results = BattleSkills.opposed_result_title(self.name1, successes1, self.name2, successes2)
          
        message = t('battleskills.opposed_roll_result', 
           :name1 => !model1 ? t('battleskills.npc', :name => self.name1) : model1.name,
           :name2 => !model2 ? t('battleskills.npc', :name => self.name2) : model2.name,
           :roll1 => self.roll_str1,
           :roll2 => self.roll_str2,
           :dice1 => BattleSkills.print_dice(die_result1),
           :dice2 => BattleSkills.print_dice(die_result2),
           :result => results)  
          
        BattleSkills.emit_results message, client, enactor_room, false
      end
    end
  end
end
