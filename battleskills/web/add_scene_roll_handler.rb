module AresMUSH
  module BattleSkills
    class AddSceneRollRequestHandler
      def handle(request)
        scene = Scene[request.args[:scene_id]]
        enactor = request.enactor
        roll_str = request.args[:roll_string]
        vs_roll1 = request.args[:vs_roll1] || ""
        vs_roll2 = request.args[:vs_roll2] || ""
        vs_name1 = request.args[:vs_name1] || ""
        vs_name2 = request.args[:vs_name2] || ""
        
        if (!scene)
          return { error: t('webportal.not_found') }
        end
        
        error = Website.check_login(request)
        return error if error

        if (!Scenes.can_read_scene?(enactor, scene))
          return { error: t('scenes.access_not_allowed') }
        end
        
        if (scene.completed)
          return { error: t('scenes.scene_already_completed') }
        end
        
        if (!vs_roll1.blank?)
          result = ClassTargetFinder.find(vs_name1, Character, enactor)
          model1 = result.target
          if (!model1 && !vs_roll1.is_integer?)
            vs_roll1 = "3"
          end
                                
          result = ClassTargetFinder.find(vs_name2, Character, enactor)
          model2 = result.target
          vs_name2 = model2 ? model2.name : vs_name2
                                
          if (!model2 && !vs_roll2.is_integer?)
            vs_roll2 = "3"
          end
          
          die_result1 = BattleSkills.parse_and_roll(model1, vs_roll1)
          die_result2 = BattleSkills.parse_and_roll(model2, vs_roll2)
          
          if (!die_result1 || !die_result2)
            return { error: t('battleskills.unknown_roll_params') }
          end
          
          successes1 = BattleSkills.get_success_level(die_result1)
          successes2 = BattleSkills.get_success_level(die_result2)
            
          results = BattleSkills.opposed_result_title(vs_name1, successes1, vs_name2, successes2)
          
          message = t('battleskills.opposed_roll_result', 
             :name1 => !model1 ? t('battleskills.npc', :name => vs_name1) : model1.name,
             :name2 => !model2 ? t('battleskills.npc', :name => vs_name2) : model2.name,
             :roll1 => vs_roll1,
             :roll2 => vs_roll2,
             :dice1 => BattleSkills.print_dice(die_result1),
             :dice2 => BattleSkills.print_dice(die_result2),
             :result => results)  
             
        else
          roll = BattleSkills.parse_and_roll(enactor, roll_str)
          roll_result = BattleSkills.get_success_level(roll)
          success_title = BattleSkills.get_success_title(roll_result)
          message = t('battleskills.simple_roll_result', 
            :name => enactor.name,
            :roll => roll_str,
            :dice => BattleSkills.print_dice(roll),
            :success => success_title
            )
        end
        
        Scenes.add_to_scene(scene, message, Game.master.system_character)
        
        if (scene.room)
          scene.room.emit message
        end
        
        {
        }
      end
    end
  end
end